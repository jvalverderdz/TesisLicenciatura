/*******************************************************************************
C2_PreparacionEMOVI.do
Author: Javier Valverde
Version: 2.0
Input:
	-ESRU-EMOVI 2017 Entrevistado.dta

Este script hace las modificaciones de nombre y creación de variables de interés
del dataset de la EMOVI 2017, y guarda el dataset resultante  para su posterior
análisis en otros scripts.

Actualización:
La versión 2.0 es una actualización de Do_PreparacionEMOVI.do para concentrar y
estandarizar la preparación de la base.

*******************************************************************************/
clear all
set more off
cls

grstyle init
grstyle set color economist
grstyle color background white

*Raíz de ubicación de archivos. Cambiar si se trabaja en otro equipo
*******************************************************************************
gl root "D:/Javier/Documents/Tesis/"
*******************************************************************************


cd "$root/Data"

gl raw "$root/Data/EMOVI/EMOVI 2017"
gl temp "$root/Capitulo 2/Data_C2/Temp"
gl output "$root/Data/EMOVI/EMOVI 2017"


*Preparación de la base de datos de la EMOVI 2017 para su exploración

clear
*Importación de la base
use "$raw/ESRU-EMOVI 2017 Entrevistado.dta", clear

{
*Renombrar variables relevantes
rename p05 edad
rename p06 sexo
rename p12 asistencia
rename p13 nivel
rename p13_1 certificado
rename p14 grado
rename p15 condicion_empleo

rename p39 p_indigena
rename p39m m_indigena
gen pp_indigena = 0
replace pp_indigena = 1 if p_indigena == 1
replace pp_indigena = 1 if m_indigena == 1

rename p63a primaria_privada
rename p63b_1 secundaria_t_privada
rename p63b_2 secundaria_g_privada
rename p63c_1 preparatoria_t_privada
rename p63c_2 preparatoria_g_privada
rename p63d universidad_privada


rename p132 numero_ingresos
rename p133 ingresos_hogar
rename p98 edad_primer_trabajo

gen experiencia = edad - edad_primer_trabajo

replace sexo = 0 if sexo == 1
replace sexo = 1 if sexo == 2

label define lbsexo 0 "Hombre" 1 "Mujer"
label values sexo lbsexo

rename p147 decil_actual_ap
rename p148 decil_origen_ap


}

{
*========================ESCOLARIDAD DEL ENTREVISTADO============================
*Crear variable de años de escolaridad basada en el nivel de escolaridad
gen escolaridad = .
replace escolaridad = 6 if nivel == 2
replace escolaridad = 9 if nivel == 3 | nivel == 4
replace escolaridad = 12 if nivel == 5 | nivel == 6 | nivel == 7 | nivel == 9
replace escolaridad = 16 if nivel == 8 | nivel == 10 | nivel == 11
replace escolaridad = 18 if nivel == 12
replace escolaridad = 0 if nivel == 97 | nivel == 1

*Reducir los años de escolaridad en caso de no haber tenido el certificado, y ajustar
*por únicamente los años que cursó
replace escolaridad = escolaridad - (6 - grado) if escolaridad == 6
replace escolaridad = escolaridad - (3 - grado) if escolaridad > 6 & escolaridad < 16 
replace escolaridad = escolaridad - (4 - grado) if escolaridad >= 16 & escolaridad < 18
replace escolaridad = escolaridad - (2 - grado) if escolaridad == 18


********************
*Exploración de características de la educación del entrevistado (privada o pública)	
gen secundaria_privada = secundaria_g_privada
replace secundaria_privada = secundaria_t_privada if secundaria_privada == .

gen preparatoria_privada = preparatoria_g_privada
replace preparatoria_privada = preparatoria_t_privada if preparatoria_privada == .

gen educacion_privada = primaria_privada
replace educacion_privada = secundaria_privada if secundaria_privada != .
replace educacion_privada = preparatoria_privada if preparatoria_privada != .
replace educacion_privada = universidad_privada if universidad_privada !=.

replace educacion_privada = 1 if educacion_privada == 1 | educacion_privada == 2
replace educacion_privada = 0 if educacion_privada == 3 | educacion_privada == 4
replace educacion_privada = . if educacion_privada == 8

label define lbeducacion_privada 0 "Pública" 1 "Privada"
label values educacion_privada lbeducacion_privada

label define lbingresos_hogar 0 "Sin Ingresos" 1 "< 1 SM" 2 "1 SM" 3 "1 a 2 SM" 4 "2 a 3 SM" 5 "3 a 5 SM" 6 "5 a 10 SM" 7 "> 10 SM"
label values ingresos_hogar lbingresos_hogar


}

{
*=======================ESCOLARIDAD DE LOS PADRES====================================
rename p43 nivel_padre 
rename p44 grado_padre
rename p43m nivel_madre
rename p44m grado_madre

gen p_escolaridad = .
gen m_escolaridad = .

replace p_escolaridad = 6 if nivel_padre == 2
replace p_escolaridad = 9 if nivel_padre == 3 | nivel_padre == 4
replace p_escolaridad = 12 if nivel_padre == 5 | nivel_padre == 6 | nivel_padre == 7 | nivel_padre == 9
replace p_escolaridad = 16 if nivel_padre == 8 | nivel_padre == 10 | nivel_padre == 11
replace p_escolaridad = 18 if nivel_padre == 12
replace p_escolaridad = 0 if nivel_padre == 97 | nivel_padre == 1

replace m_escolaridad = 6 if nivel_madre == 2
replace m_escolaridad = 9 if nivel_madre == 3 | nivel_madre == 4
replace m_escolaridad = 12 if nivel_madre == 5 | nivel_madre == 6 | nivel_madre == 7 | nivel_madre == 9
replace m_escolaridad = 16 if nivel_madre == 8 | nivel_madre == 10 | nivel_madre == 11
replace m_escolaridad = 18 if nivel_madre == 12
replace m_escolaridad = 0 if nivel_madre == 97 | nivel_madre == 1

*--------------
replace p_escolaridad = p_escolaridad - (6 - grado_padre) if p_escolaridad == 6
replace p_escolaridad = p_escolaridad - (3 - grado_padre) if p_escolaridad > 6 & p_escolaridad < 16 
replace p_escolaridad = p_escolaridad - (4 - grado_padre) if p_escolaridad >= 16 & p_escolaridad < 18
replace p_escolaridad = p_escolaridad - (2 - grado_padre) if p_escolaridad == 18

replace m_escolaridad = m_escolaridad - (6 - grado_madre) if m_escolaridad == 6
replace m_escolaridad = m_escolaridad - (3 - grado_madre) if m_escolaridad > 6 & m_escolaridad < 16 
replace m_escolaridad = m_escolaridad - (4 - grado_madre) if m_escolaridad >= 16 & m_escolaridad < 18
replace m_escolaridad = m_escolaridad - (2 - grado_madre) if m_escolaridad == 18

gen pp_escolaridad = (m_escolaridad + p_escolaridad)/2 //Generamos una variable de escolaridad promedio de padres (de todos modos como están correlacionadas va a dar algo parecido

}

******NIveles de Escolaridad (entrevistado y padres)*****
*Entrevistado
gen nivel_escolaridad = .
replace nivel_escolaridad = 0 if escolaridad == 0
replace nivel_escolaridad = 1 if escolaridad > 0 & escolaridad < 6
replace nivel_escolaridad = 2 if escolaridad == 6
replace nivel_escolaridad = 3 if escolaridad > 6 & escolaridad < 9
replace nivel_escolaridad = 4 if escolaridad == 9
replace nivel_escolaridad = 5 if escolaridad > 9 & escolaridad < 12
replace nivel_escolaridad = 6 if escolaridad == 12
replace nivel_escolaridad = 7 if escolaridad > 12 & escolaridad < 16
replace nivel_escolaridad = 8 if escolaridad >= 16

label define lbnivel_escolaridad 0 "Sin Estudios" 1 "Primaria Incompleta" 2 "Primaria" 3 "Secundaria Incompleta" 4 "Secundaria" 5 "Preparatoria Incompleta" 6 "Preparatoria" 7 "Superior Incompleta" 8 "Superior"
label values nivel_escolaridad lbnivel_escolaridad


*Padre
gen nivel_p_escolaridad = .
replace nivel_p_escolaridad = 0 if p_escolaridad == 0
replace nivel_p_escolaridad = 1 if p_escolaridad > 0 & p_escolaridad < 6
replace nivel_p_escolaridad = 2 if p_escolaridad == 6
replace nivel_p_escolaridad = 3 if p_escolaridad > 6 & p_escolaridad < 9
replace nivel_p_escolaridad = 4 if p_escolaridad == 9
replace nivel_p_escolaridad = 5 if p_escolaridad > 9 & p_escolaridad < 12
replace nivel_p_escolaridad = 6 if p_escolaridad == 12
replace nivel_p_escolaridad = 7 if p_escolaridad > 12 & p_escolaridad < 16
replace nivel_p_escolaridad = 8 if p_escolaridad >= 16 & p_escolaridad != .

label define lbnivel_p_escolaridad 0 "Sin Estudios" 1 "Primaria Incompleta" 2 "Primaria" 3 "Secundaria Incompleta" 4 "Secundaria" 5 "Preparatoria Incompleta" 6 "Preparatoria" 7 "Superior Incompleta" 8 "Superior"
label values nivel_p_escolaridad lbnivel_p_escolaridad


*Madre
gen nivel_m_escolaridad = .
replace nivel_m_escolaridad = 0 if m_escolaridad == 0
replace nivel_m_escolaridad = 1 if m_escolaridad > 0 & m_escolaridad < 6
replace nivel_m_escolaridad = 2 if m_escolaridad == 6
replace nivel_m_escolaridad = 3 if m_escolaridad > 6 & m_escolaridad < 9
replace nivel_m_escolaridad = 4 if m_escolaridad == 9
replace nivel_m_escolaridad = 5 if m_escolaridad > 9 & m_escolaridad < 12
replace nivel_m_escolaridad = 6 if m_escolaridad == 12
replace nivel_m_escolaridad = 7 if m_escolaridad > 12 & m_escolaridad < 16
replace nivel_m_escolaridad = 8 if m_escolaridad >= 16 & m_escolaridad != .

label define lbnivel_m_escolaridad 0 "Sin Estudios" 1 "Primaria Incompleta" 2 "Primaria" 3 "Secundaria Incompleta" 4 "Secundaria" 5 "Preparatoria Incompleta" 6 "Preparatoria" 7 "Superior Incompleta" 8 "Superior"
label values nivel_m_escolaridad lbnivel_m_escolaridad

*Padres

gen nivel_pp_escolaridad = .
replace nivel_pp_escolaridad = 0 if pp_escolaridad == 0
replace nivel_pp_escolaridad = 1 if pp_escolaridad > 0 & pp_escolaridad < 6
replace nivel_pp_escolaridad = 2 if pp_escolaridad == 6
replace nivel_pp_escolaridad = 3 if pp_escolaridad > 6 & pp_escolaridad < 9
replace nivel_pp_escolaridad = 4 if pp_escolaridad == 9
replace nivel_pp_escolaridad = 5 if pp_escolaridad > 9 & pp_escolaridad < 12
replace nivel_pp_escolaridad = 6 if pp_escolaridad == 12
replace nivel_pp_escolaridad = 7 if pp_escolaridad > 12 & pp_escolaridad < 16
replace nivel_pp_escolaridad = 8 if pp_escolaridad >= 16 & pp_escolaridad != .

label define lbnivel_pp_escolaridad 0 "Sin Estudios" 1 "Primaria Incompleta" 2 "Primaria" 3 "Secundaria Incompleta" 4 "Secundaria" 5 "Preparatoria Incompleta" 6 "Preparatoria" 7 "Superior Incompleta" 8 "Superior"
label values nivel_pp_escolaridad lbnivel_pp_escolaridad




{
*=======================INGRESO========================================
replace ingresos_hogar = 0 if ingresos_hogar == 8 | ingresos_hogar == 9

gen ingresos_hogar2 = .
replace ingresos_hogar2 = ingresos_hogar/numero_ingresos if numero_ingresos != 0
replace ingresos_hogar2 = 0 if ingresos_hogar == 0

replace condicion_empleo = 0 if condicion_empleo != 1
}


*=======================GUARDAR DATABASE========================================
save "$output/ESRU-EMOVI 2017 Entrevistado_ModificacionJV200511.dta", replace
	