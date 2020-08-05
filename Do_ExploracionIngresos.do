*Preparación de la base de datos de la EMOVI 2017 para su exploración

clear
*Importación de la base
use "D:\Javier\Documents\Tesis\Databases Tesis\EMOVI\EMOVI 2017\ESRU-EMOVI 2017 Entrevistado_ModificacionJV200511.dta", clear

{
*Exploración de las variables de ingreso
sum ingresos_hogar [fw = factor] if condicion_empleo == 1
hist ingresos_hogar [fw = factor] if ingresos_hogar != 0 & condicion_empleo == 1

scatter ingresos_hogar escolaridad [fw = factor], msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1

correlate ingresos_hogar escolaridad experiencia [fw = factor] if condicion_empleo == 1 & ingresos_hogar != .

scatter ingresos_hogar experiencia [fw = factor], msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar experiencia [fw = factor] if condicion_empleo == 1

gen ln_ingresos_hogar = ln(ingresos_hogar)
gen ln_escolaridad = ln(escolaridad)
gen ln_experiencia = ln(experiencia)

reg ln_ingresos_hogar ln_escolaridad ln_experiencia i.sexo [fw = factor] if ln_ingresos_hogar != . & condicion_empleo == 1

predict ln_u1, resid
hist ln_u1, norm

reg ingresos_hogar escolaridad experiencia i.sexo [fw = factor] if ingresos_hogar != . & condicion_empleo == 1
predict u1, resid
hist u1, norm




reg ln_ingresos_hogar ln_escolaridad ln_experiencia i.sexo [fw = factor] if ln_ingresos_hogar != . & condicion_empleo == 1
