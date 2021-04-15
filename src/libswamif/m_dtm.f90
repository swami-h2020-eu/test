! ---------------------------------------------------------------------
! – Project : SWAMI
! – Customer : N/A
! ---------------------------------------------------------------------
! – Author : Daniel Lubián Arenillas
! – Issue : 1.0
! – Date : 2021-03-31
! – Purpose : Module to wrap DTM
! - Component : m_dtm
! ---------------------------------------------------------------------
! – © Copyright Deimos Space SLU, 2021
! – All rights reserved
! ---------------------------------------------------------------------

module m_dtm
    implicit none

    real(8), private, parameter :: PI = acos(-1d0)
    real(8), private, parameter :: DEG2RAD = PI/180d0
    real(8), private, parameter :: HOUR2RAD = PI/12d0
    character(50), public:: DTM2020_DATA_FILENAME = "DTM_2020_F107_Kp.dat"

    public :: get_dtm2020
    public :: get_dtm2020_dens_uncertainty

    external :: sigma_function, dtm3, lecdtm

contains
    subroutine get_dtm2020(dens, temp, alti, lati, longi, loct, doy, f107, f107m, kps)
        ! Get air density and temperature from DTM model

        implicit none
        real(8), intent(out) :: dens            ! Density (g/cm^3)
        real(8), intent(out) :: temp            ! Temperature (K)
        real(8), intent(in) :: alti             ! Altitude (km) [120-]
        real(8), intent(in) :: lati             ! Latitude (deg) [-90, 90]
        real(8), intent(in) :: longi             ! Longitude (deg) [0, 360]
        real(8), intent(in) :: loct             ! Local time (h) [0, 24]
        real(8), intent(in) :: doy              ! Day of the year [0-366]
        real(8), intent(in) :: f107             ! Space weather index F10.7, instantaneous flux at (t - 24hr)
        real(8), intent(in) :: f107m            ! Space weather index F10.7, average flux at time
        real(8), intent(in) :: kps(2)           ! Space weather index: kp delayed by 3 hours (1st value), kp mean of last 24 hours (2nd value)

        real(4) :: f(2), fbar(2), akp(4), dens4, temp4

        f = [real(f107), 0e0]
        fbar = [real(f107m), 0.0]
        akp = [real(kps(1)), 0.0, real(kps(2)), 0.0]

        call wrapper_dtm2020(doy=real(doy), f=f, fbar=fbar, akp=akp, &
                     alti=real(alti), loct=real(loct*HOUR2RAD), lati=real(lati*DEG2RAD), longi=real(longi*DEG2RAD), &
                     temp=temp4, dens=dens4)
        temp = dble(temp4)
        dens = dble(dens4)

    end subroutine get_dtm2020

    subroutine get_dtm2020_dens_uncertainty(unc, alti, lati, longi, loct, doy, f107, f107m, kps)
        ! Get air density uncertainty from DTM model. It is the percentage of the density value at those coordinates

        real(8), intent(out) :: unc             ! Uncertainty of the density: returns 1-sigma value.
        real(8), intent(in) :: alti             ! Altitude (km) [120-]
        real(8), intent(in) :: lati             ! Latitude (deg) [-90, 90]
        real(8), intent(in) :: longi             ! Longitude (deg) [0, 360]
        real(8), intent(in) :: loct             ! Local time (h) [0, 24]
        real(8), intent(in) :: doy              ! Day of the year [0-366]
        real(8), intent(in) :: f107             ! Space weather index F10.7, instantaneous flux at (t - 24hr)
        real(8), intent(in) :: f107m            ! Space weather index F10.7, average flux at time
        real(8), intent(in) :: kps(2)           ! Space weather index: kp delayed by 3 hours (1st value), kp mean of last 24 hours (2nd value)

        real(4) :: unc4

        call sigma_function(real(lati), real(loct), real(doy), real(alti), real(f107m), real(kps(1)), unc4)

        unc = dble(unc4)

    end subroutine get_dtm2020_dens_uncertainty

    subroutine init_dtm2020(data_file)
        ! Initialise DTM model (load into memory)

        implicit none
        character(*), intent(in) :: data_file

        open (unit=42, file=trim(data_file))
        call lecdtm(42)
        close (42)

    end subroutine init_dtm2020

    subroutine wrapper_dtm2020(doy, f, fbar, akp, alti, loct, lati, longi, temp, dens)

        implicit none
        !
        !.. Parameters ..
        !
        !.. Formal Arguments ..
        real, intent(in) :: lati, alti, doy, loct, longi
        real, dimension(2), intent(in) :: f, fbar
        real, dimension(4), intent(in) :: akp
        real, intent(out) :: dens, temp

        real :: d(6), wmm, tinf

        call dtm3(doy, f, fbar, akp, &
                  alti, loct, lati, longi, &
                  temp, tinf, dens, d, wmm)

    end subroutine wrapper_dtm2020

end module m_dtm
