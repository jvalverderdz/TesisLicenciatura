/*******************************************************************************
C2_ExploracionEMOVI.do
Author: Javier Valverde
Version: 2.0
Input:
	-ESRU-EMOVI 2017 Entrevistado_ModificacionJV200511.dta

Este Script hace análisis exploratorio de la base de EMOVI 2017. Genera tablas
y gráficas de información de escolaridad, trabajo, ingresos y características
del hogar de origen.

Actualización:
La versión 2.0 es una actualización de Do_PreparacionEMOVI.do y
Do_PreparacionEMOVI_Segmentado.do con versiones y estilos actualizados de las
gráficas que ahora sí van a ir en el documento

*******************************************************************************/
 
clear all
set more off
cls

grstyle init
grstyle set color economist
grstyle color background white

*******************************************************************************

*Raíz de ubicación de archivos. Cambiar si se trabaja en otro equipo
*******************************************************************************
gl root "D:/Javier/Documents/Tesis/"
*******************************************************************************



cd "$root/Capitulo 2/Data_C2"

gl raw "$root/Databases Tesis/EMOVI/EMOVI 2017"
gl graphs "$root/Capitulo 2/Data_C2/Graphs"
gl temp "$root/Capitulo 2/Data_C2/Temp"




*******************************************************************************
use "D:\Javier\Documents\Tesis\Data\EMOVI\EMOVI 2017\ESRU-EMOVI 2017 Entrevistado_ModificacionJV200511.dta", clear
*******************************************************************************

*********PARTE 5.1: Escolaridad**********

*5.1.1. Distribución de los niveles de escolaridad
egen total_factor = sum(factor)
gen small_factor = factor/total_factor
gen perc_factor = (factor / total_factor) * 100


graph hbar (sum) perc_factor, over(nivel_escolaridad) ytitle("%")
graph export "$graphs/511_NivelesEscolaridad.png", width(1020) replace 

*5.1.2. Distribución de escolaridad por sexo
graph box escolaridad [fw = factor], over(sexo) ytitle("Escolaridad")
graph export "$graphs/512_Escolaridad_PorSexo.png", width(1020) replace

*5.1.3. Distribución de escolaridad por región
graph box escolaridad [fw = factor], over(region) ytitle("Escolaridad")
graph export "$graphs/513_Escolaridad_PorRegion.png", width(1020) replace

*5.1.4. Pasteles de propiedad/subsistema de la escuela del entrevistado
graph pie factor, over(educacion_privada) plabel(_all percent, color(white))
graph export "$graphs/514_Propiedad.png", width(1020) replace

*5.1.5. Escolaridad por Propietario
egen total_prop = sum(factor), by(educacion_privada)
gen perc_prop = (factor / total_prop) * 100
graph bar (sum) perc_prop, over(nivel_escolaridad, label(angle(90))) by(educacion_privada) ytitle(%)
graph export "$graphs/515_NivelesEscolaridad_PorPropietario.png", width(1020) replace


*5.1.6. Escolaridad por decil de origen autopercibido
graph bar (median) escolaridad [fw = factor], over(decil_origen_ap) ytitle("Escolaridad")
graph export "$graphs/516_Escolaridad_PorDecilAP.png", width(1020) replace


*******************************************************************************
*********PARTE 5.2: Escolaridad de los Padres**********

*5.2.1. Distribuciones de la escolaridad de los padres
graph hbar (sum) perc_factor, over(nivel_p_escolaridad) ytitle("%")
graph export "$graphs/521a_EscolaridadPadre.png", width(1020) replace

graph hbar (sum) perc_factor, over(nivel_m_escolaridad) ytitle("%")
graph export "$graphs/521b_EscolaridadMadre.png", width(1020) replace

*5.2.2. Correlación de la escolaridad de ambos padres
correlate p_escolaridad m_escolaridad

*5.2.3. Correlación entre escolaridad del entrevistado y de los padres
correlate escolaridad pp_escolaridad

twoway contour perc_factor escolaridad pp_escolaridad, ccuts(0 0.002 0.004 0.006 0.008 0.01 0.015 0.02 0.03 0.04) heatmap ytitle("Escolaridad del entrevistado") xtitle("Escolaridad de los padres") ztitle("Densidad")
graph export "$graphs/523_Correlacion_Escolaridades_HijoPadres.png", width(1020) replace


*******************************************************************************
*********PARTE 5.3: Ingresos**********

*5.3.1. Distribución de ingresos del entrevistado
graph hbar (sum) perc_factor if ingresos_hogar != 0, over(ingresos_hogar) ytitle("Densidad")
graph export "$graphs/531_Ingresos.png", width(1020) replace


*5.3.2. Distribución de ingresos según nivel educativo (heattable heatmap, o barras agrupadas)
tab escolaridad ingresos_hogar [fw = factor], row
tab escolaridad ingresos_hogar [fw = factor], col
	**Todo esto mejor lo agarré del Excel. Es más sencillo y más ilustrativo



*5.3.3. Ingresos según propiedad de la escuela (distribuciones y lineas)
preserve
	drop if ingresos_hogar == 0
	graph bar (sum) perc_prop if ingresos_hogar != 0, over(ingresos_hogar, label(angle(90))) over(educacion_privada) ytitle("Densidad")
	graph export "$graphs/533_Ingresos_PorPropiedad.png", width(1020) replace
restore


*5.3.4. Ingresos según decil autopercibido de origen (distribuciones y lineas)
egen total_decil = sum(factor), by(decil_origen_ap)
gen perc_decil = (factor / total_decil) * 100

graph bar (sum) perc_decil if ingresos_hogar == 7, over(decil_origen_ap) ytitle("Densidad")
graph export "$graphs/534a_Ingresos_PorDecil.png", width(1020) replace

graph bar (sum) perc_decil if ingresos_hogar == 1, over(decil_origen_ap) ytitle("Densidad")
graph export "$graphs/534b_Ingresos_PorDecil.png", width(1020) replace


*5.3.5. Distribución de deciles autopercibidos (Esto va para el Anexo)
graph bar (sum) perc_factor, over(decil_origen_ap) ytitle("Densidad")
graph export "$graphs/535_Distribucion_DecilesAutopercibidos.png", width(1020) replace


*5.3.6. Ingreso y escolaridad
graph bar (mean) escolaridad [fw = factor] if ingresos_hogar != 0, over(ingresos_hogar) ytitle("Escolaridad promedio")
graph export "$graphs/536a_Escolaridad_PorIngreso.png", width(1020) replace

graph box escolaridad [fw = factor] if ingresos_hogar != 0, over(ingresos_hogar) ytitle("Escolaridad promedio")
graph export "$graphs/536b_Escolaridad_PorIngreso_BoxPlot.png", width(1020) replace


*5.3.7. Ingreso y escolaridad de los padres
graph bar (mean) pp_escolaridad [fw = factor] if ingresos_hogar != 0, over(ingresos_hogar) ytitle("Escolaridad promedio")
graph export "$graphs/537_EscolaridadPadres_PorIngreso.png", width(1020) replace


*5.3.8. Correlaciones de ingreso y escolaridad
corr escolaridad ingresos_hogar [fw = factor]

corr escolaridad ingresos_hogar if educacion_privada == 0 [fw = factor]
corr escolaridad ingresos_hogar if educacion_privada == 1 [fw = factor]

cls
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 1 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 2 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 3 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 4 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 5 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 6 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 7 [fw = factor]
corr escolaridad ingresos_hogar if nivel_pp_escolaridad == 8 [fw = factor]

