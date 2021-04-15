! ---------------------------------------------------------------------
! – Project : SWAMI
! – Customer : N/A
! ---------------------------------------------------------------------
! – Author : Daniel Lubián Arenillas
! – Issue : 1.0
! – Date : 2021-03-31
! – Purpose : Provides main MCM functions
! - Component : m_mcm
! ---------------------------------------------------------------------
! – © Copyright Deimos Space SLU, 2021
! – All rights reserved
! ---------------------------------------------------------------------

module m_mcm
    use m_um, only: get_um_dens, get_um_temp, get_um_dens_standard_deviation, get_um_temp_standard_deviation, init_um
    use m_dtm, only: get_dtm2020, DTM2020_DATA_FILENAME, init_dtm2020, get_dtm2020_dens_uncertainty
    use m_interp, only: interp1d_linear, loge_linear_segment, linear_segment

    implicit none

    real(8), parameter, private :: BLENDING_ALTI_RANGE_LOW = 100.0d0  ! Transition region: lower altitude
    real(8), parameter, private :: BLENDING_ALTI_RANGE_HIGH = 120.0d0  ! Transition region: higher altitude
    real(8), parameter, private :: PI = acos(-1d0)
    real(8), parameter, private :: HOUR2RAD = PI/12.d0

    public :: get_mcm_dens
    public :: get_mcm_temp

contains

    subroutine init_mcm(data_um, data_dtm)
        ! Initialise MCM model by loading UM and DTM data into memory

        implicit none
        character(*), intent(in) :: data_um     ! Path to UM files
        character(*), intent(in) :: data_dtm    ! Path directory where to find DTM2020 data file

        call init_dtm2020(trim(data_dtm)//trim(DTM2020_DATA_FILENAME))
        call init_um(trim(data_um))

    end subroutine init_mcm

    subroutine get_mcm_dens(dens, alti, lati, longi, loct, doy, f107, f107m, kps)
        ! | Get air density from the MOWA Climatological model, blended model of UM and DTM
        ! - Below 120km, UM tables are used.
        ! - Between 120 and 152, both models are combined with a transition function
        ! - Higher than 152, only DTM is used

        real(8), intent(out) :: dens                ! Air density, in g/cm3
        real(8), intent(in) :: alti                 ! Altitude, in km
        real(8), intent(in) :: lati                 ! Latitude, in degrees [-90,+90]
        real(8), intent(in) :: longi                 ! Longitude, in degrees [0, 360), east positive
        real(8), intent(in) :: loct                 ! Local time, in hours [0, 24)
        real(8), intent(in) :: doy                  ! Day of the year [0-366)
        real(8), intent(in) :: f107                 ! Space weather index F10.7, instantaneous flux at (t - 24hr)
        real(8), intent(in) :: f107m                ! Space weather index F10.7, average flux at time
        real(8), intent(in) :: kps(2)               ! Space weather index: kp delayed by 3 hours (1st value), kp mean of last 24 hours (2nd value)

        real(8) :: um = 0.0d0
        real(8) :: dtm = 0.0d0
        real(8) :: aux

        if (alti < BLENDING_ALTI_RANGE_LOW) then
            call get_um_dens(um, alti, lati, longi, loct, doy, f107, f107m, kps)
            dens = um

        else if (alti > BLENDING_ALTI_RANGE_HIGH) then
            call get_dtm2020(dtm, aux, alti, lati, longi, loct, doy, f107, f107m, kps)
            dens = dtm

        else
            call get_um_dens(um, BLENDING_ALTI_RANGE_LOW, lati, longi, loct, doy, f107, f107m, kps)
            call get_dtm2020(dtm, aux, BLENDING_ALTI_RANGE_HIGH, lati, longi, loct, doy, f107, f107m, kps)

            dens = loge_linear_segment(BLENDING_ALTI_RANGE_LOW, BLENDING_ALTI_RANGE_HIGH, um, dtm, alti)
            ! dens = log10_linear_segment(BLENDING_ALTI_RANGE_LOW, BLENDING_ALTI_RANGE_HIGH, um, dtm, alti)

        end if

    end subroutine get_mcm_dens

    subroutine get_mcm_temp(temp, alti, lati, longi, loct, doy, f107, f107m, kps)
        ! | Get air temperature from the MOWA Climatological model, blended model of UM and DTM
        ! - Below 120km, UM tables are used.
        ! - Between 120 and 152, both models are combined with a transition function
        ! - Higher than 152, only DTM is used

        real(8), intent(out) :: temp                ! Air temperature, in K
        real(8), intent(in) :: alti                 ! Altitude, in km
        real(8), intent(in) :: lati                 ! Latitude, in degrees [-90,+90]
        real(8), intent(in) :: longi                 ! Longitude, in degrees [0, 360), east positive
        real(8), intent(in) :: loct                 ! Local time, in hours [0, 24)
        real(8), intent(in) :: doy                  ! Day of the year [0-366)
        real(8), intent(in) :: f107                 ! Space weather index F10.7, instantaneous flux at (t - 24hr)
        real(8), intent(in) :: f107m                ! Space weather index F10.7, average flux at time
        real(8), intent(in) :: kps(2)               ! Space weather index: kp delayed by 3 hours (1st value), kp mean of last 24 hours (2nd value)

        real(8) :: um = 0.0d0
        real(8) :: dtm = 0.0d0
        real(8) :: aux

        if (alti < BLENDING_ALTI_RANGE_LOW) then
            call get_um_temp(um, alti, lati, longi, loct, doy, f107, f107m, kps)
            temp = um

        else if (alti > BLENDING_ALTI_RANGE_HIGH) then
            call get_dtm2020(aux, dtm, alti, lati, longi, loct, doy, f107, f107m, kps)
            temp = dtm

        else
            call get_um_temp(um, BLENDING_ALTI_RANGE_LOW, lati, longi, loct, doy, f107, f107m, kps)
            call get_dtm2020(aux, dtm, BLENDING_ALTI_RANGE_HIGH, lati, longi, loct, doy, f107, f107m, kps)

            temp = linear_segment(BLENDING_ALTI_RANGE_LOW, BLENDING_ALTI_RANGE_HIGH, um, dtm, alti)
        end if

    end subroutine get_mcm_temp

end module m_mcm
