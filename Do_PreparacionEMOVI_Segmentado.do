*Preparación de la base de datos de la EMOVI 2017 para su exploración

clear
*Importación de la base
use "D:\Javier\Documents\Tesis\Databases Tesis\EMOVI\EMOVI 2017\ESRU-EMOVI 2017 Entrevistado.dta", clear

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

*====EXPLORACIÓN DE DATOS SEGMENTADOS==================================0

{
*Exploración de las variables de escolaridad e ingresos

sum escolaridad [fw = factor] if educacion_privada == 1
sum escolaridad [fw = factor] if educacion_privada == 0

hist escolaridad [fw = factor], by(educacion_privada) bin(10)

hist escolaridad [fw = factor] if pp_escolaridad < 6
hist escolaridad [fw = factor] if pp_escolaridad < 9
hist escolaridad [fw = factor] if pp_escolaridad >= 9 & pp_escolaridad < 12
hist escolaridad [fw = factor] if pp_escolaridad >= 12 & pp_escolaridad < 16
hist escolaridad [fw = factor] if pp_escolaridad >= 16

*---
sum ingresos_hogar [fw = factor] if educacion_privada == 1
sum ingresos_hogar [fw = factor] if educacion_privada == 0

tabulate ingresos_hogar [fw = factor] if educacion_privada == 1
tabulate ingresos_hogar [fw = factor] if educacion_privada == 0

hist ingresos_hogar [fw = factor], by(educacion_privada)


sum ingresos_hogar [fw = factor] if pp_escolaridad < 9
sum ingresos_hogar [fw = factor] if pp_escolaridad >= 9 & pp_escolaridad < 12
sum ingresos_hogar [fw = factor] if pp_escolaridad > 12

hist ingresos_hogar [fw = factor], by pp_escolaridad


hist ingresos_hogar [fw = factor] if pp_escolaridad < 9
hist ingresos_hogar [fw = factor] if pp_escolaridad >= 9 & pp_escolaridad < 12
hist ingresos_hogar [fw = factor] if pp_escolaridad > 12


scatter ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1, msymbol(circle_hollow) msize(0.2)  by(educacion_privada) || lfit ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1, by(educacion_privada)

scatter ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1 & ingresos_hogar != 0 & educacion_privada == 1, msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1 & ingresos_hogar != 0 & educacion_privada == 1
scatter ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1 & ingresos_hogar != 0 & educacion_privada == 0, msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar escolaridad [fw = factor] if condicion_empleo == 1 & ingresos_hogar != 0 & educacion_privada == 0


graph pie factor [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1, over(ingresos_hogar) title("Ingresos de los egresados de escuelas privadas")
graph pie factor [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0, over(ingresos_hogar) title("Ingresos de los egresados de escuelas públicas")

}



{
*Exploración de las correlaciones segmentadas

heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0)
 
heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1)
heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0)


heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad < 9, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad < 9)
heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 9 & pp_escolaridad < 16, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 9 & pp_escolaridad < 16)
heatplot ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 16, addplot(lfit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 16)
 

correlate ingresos_hogar escolaridad experiencia [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1
correlate ingresos_hogar escolaridad experiencia [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0

correlate ingresos_hogar escolaridad experiencia [fw = factor] if ingresos_hogar != 0 & pp_escolaridad < 9
correlate ingresos_hogar escolaridad experiencia [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 9 & pp_escolaridad < 16
correlate ingresos_hogar escolaridad experiencia [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 16



gen ln_ingresos_hogar = ln(ingresos_hogar)
gen ln_escolaridad = ln(escolaridad)
gen ln_experiencia = ln(experiencia)


reg ingresos_hogar escolaridad experiencia i.sexo [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1
reg ingresos_hogar escolaridad experiencia i.sexo [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0

reg ingresos_hogar escolaridad i.sexo [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1
reg ingresos_hogar escolaridad i.sexo [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0

reg ingresos_hogar escolaridad i.sexo [fw = factor] if ingresos_hogar != 0 & pp_escolaridad < 9
reg ingresos_hogar escolaridad i.sexo [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 9 & escolaridad < 16
reg ingresos_hogar escolaridad i.sexo [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 16



reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 1
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 2
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 3
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 4
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 5
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 6
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 7
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 8
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 9
reg ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap == 10



}





{
*Exploración por tabulaciones y modelos logit

tab escolaridad ingresos_hogar [fw = factor] if ingresos_hogar != 0
tab escolaridad ingresos_hogar [fw = factor] if educacion_privada == 1 & ingresos_hogar != 0
tab escolaridad ingresos_hogar [fw = factor] if educacion_privada == 0 & ingresos_hogar != 0


tab escolaridad [fw = factor] if pp_escolaridad < 6
tab escolaridad [fw = factor] if pp_escolaridad >= 6 & pp_escolaridad < 16
tab escolaridad [fw = factor] if pp_escolaridad >= 16

tab ingresos_hogar [fw = factor] if ingresos_hogar != 0 & pp_escolaridad < 6
tab ingresos_hogar [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 6 & escolaridad < 16
tab ingresos_hogar [fw = factor] if ingresos_hogar != 0 & pp_escolaridad >= 16


*Modelo Ologit general
ologit ingresos_hogar escolaridad  [fw = factor] if ingresos_hogar != 0

mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))


*Modelo Ologit educación privada
ologit ingresos_hogar escolaridad  [fw = factor] if ingresos_hogar != 0 & educacion_privada == 1

mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))

*Modelo Ologit educación pública
ologit ingresos_hogar escolaridad  [fw = factor] if ingresos_hogar != 0 & educacion_privada == 0

mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))


*Modelo Ologit que incorpora decil de origen como variable explicativa
ologit ingresos_hogar escolaridad  decil_origen_ap [fw = factor] if ingresos_hogar != 0
mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))


*Modelos ologit para distintos niveles de hogar de origen autopercibido
ologit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap <= 3
mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))


ologit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap > 3 & decil_origen_ap <= 7
mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))

ologit ingresos_hogar escolaridad [fw = factor] if ingresos_hogar != 0 & decil_origen_ap >= 8
mfx, predict(outcome(1))
mfx, predict(outcome(2))
mfx, predict(outcome(3))
mfx, predict(outcome(4))
mfx, predict(outcome(5))
mfx, predict(outcome(6))
mfx, predict(outcome(7))
