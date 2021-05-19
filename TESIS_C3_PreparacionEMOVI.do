/*******************************************************************************
TESIS_C3_PreparacionEMOVI.do
Author: Javier Valverde
Version: 1.0
Input:
	-Data\EMOVI\EMOVI 2017

Este Do prepara la Emovi-2017 para su posterior análisis y modelado. Renombra
variables, crea índices y calcula variables relevantes para generar un .dta
utilizable.


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
gl root "D:/Javier/Documents/Tesis"
*******************************************************************************
cd "$root"

gl emovi "$root/Data/EMOVI/EMOVI 2017"
gl raw "$root/Capitulo 3/Data_C3/Raw"
gl graphs "$root/Capitulo 3/Data_C3/Graphs"
gl temp "$root/Capitulo 3/Data_C3/Temp"

*******************************************************************************

*Importación de la base
use "$emovi/ESRU-EMOVI 2017 Entrevistado.dta", clear

{
*========================RENOMBRAR VARIABLES RELEVANTES============================
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

rename p67 motivo_dejo_estudiar

rename p132 numero_ingresos
rename p133 ingresos_hogar
rename p98 edad_primer_trabajo

rename p147 decil_actual_ap
rename p148 decil_origen_ap

gen experiencia = edad - edad_primer_trabajo

replace sexo = 0 if sexo == 1
replace sexo = 1 if sexo == 2
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


{
*=======================INGRESO========================================
replace ingresos_hogar = 0 if ingresos_hogar == 8 | ingresos_hogar == 9

gen ingresos_hogar2 = .
replace ingresos_hogar2 = ingresos_hogar/numero_ingresos if numero_ingresos != 0
replace ingresos_hogar2 = 0 if ingresos_hogar == 0

replace condicion_empleo = 0 if condicion_empleo != 1
}


*=============================================================


*======================ÍNDICE DE RIQUEZA DEL HOGAR DE ORIGEN====================

foreach var of varlist p30* p32* p33* p34* {
	replace `var' = 0 if `var' != 1
}

*Índice de Activos del hogar
gen act_ind = (p30_a + p30_b + p30_c + p30_d + p30_e) / 5
replace act_ind = 0.0001 if act_ind == 0

*Servicios financieros
gen fin_ind = (p32_a + p32_b + p32_c + p32_d) / 4
replace fin_ind = 0.0001 if fin_ind == 0

*Articulos del hogar
gen art_ind = (p33_a + p33_b + p33_c + p33_d + p33_e + p33_f + p33_g + p33_h + p33_i + p33_j + p33_k + p33_l + p33_m + p33_n) / 14
replace art_ind = 0.0001 if art_ind == 0

*Bienes del hogar
gen bie_ind = (p34_a + p34_b + p34_c + p34_d + p34_e + p34_f + p34_g + p34_h) / 8
replace bie_ind = 0.0001 if bie_ind == 0

*Índice de Riqueza
gen riq_ind = (act_ind + fin_ind + art_ind + bie_ind) / 4

label variable riq_ind "Índice de Riqueza del Hogar de Origen"

egen decil_origen = xtile(riq_ind), nq(10)


*===============VARIABLES TRANSFORMADAS DE ESCOLARIDAD Y EXPERIENCIA============
gen escolaridad2 = escolaridad^2
gen ln_escolaridad = ln(escolaridad)
gen ln_experiencia = ln(experiencia)
gen experiencia2 = experiencia^2
gen ln_escolaridad2 = ln_escolaridad^2
gen ln_experiencia2 = ln_experiencia^2


*======================EXPORTAR EL DATASET RESULTANTE====================
save "$raw/emovi17.dta", replace
