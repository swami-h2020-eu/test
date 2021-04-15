Unified Model (UM)
==================


Description of the model
------------------------

The UM is the Met Office weather and climate model. In most applications the
UM has an upper boundary at around 85 km in altitude, but here we use and
describe an extended UM which has an upper boundary at 152 km.
In order to run at these higher altitudes a number of changes to the UM have been
made. The radiation scheme has been altered to represent non local
thermodynamical equilibrium (LTE) longwave cooling and shortwave heating.
This leads to more accurate heating rates in the mesosphere and lower
thermosphere. The radiation scheme also been extended to include shorter
wavelengths in the extreme and far ultraviolet range (EUV and FUV). This results
in more accurate heating rates in the thermosphere and also provides photolysis
rates which can be used in future to drive exothermic heating via the UM
chemistry scheme. This feature in not available in the current UM version and so
here the exothermic heating is approximately represented by Newtonian relaxation
(“nudging”) to climatological temperatures in the lower thermosphere.

Three 1 year-long UM simulations were run to provide input data for the MCM:
Jan-Dec 2002 (solar maximum), Jan-Dec 2004 (solar median) and Jul 2008 – Jun
2009 (solar minimum). The UM output was regridded to a lower resolution of 10º
latitude x 15º longitude for processing. Then the mean and standard deviation of
the migrating tidal signal, and the mean and standard deviation of the total field
(minus any migrating tidal signal) were calculated for each month. These
calculations were carried out for neutral density, temperature, zonal wind and
meridional wind.


Winds
-----

.. todo:: 
   
   Write winds stuff




.. admonition:: Contact information

   contact information MO