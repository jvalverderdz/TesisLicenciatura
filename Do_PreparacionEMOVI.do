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


rename p132 numero_ingresos
rename p133 ingresos_hogar
rename p98 edad_primer_trabajo

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

*====EXPLORACIÓN DE DATOS==================================0


{
*Resumenes estadístico de la escolaridad
sum escolaridad [fw = factor]
sum escolaridad [fw = factor], detail

sum escolaridad [fw = factor] if sexo == 1
sum escolaridad [fw = factor] if sexo == 2

graph box escolaridad [fw = factor], by(sexo)

hist escolaridad [fw = factor], by(sexo) bin(10)
}

{
*Resumenes estadísticos de la escolaridad según condición de la escuela (privada o pública)

hist primaria_privada [fw = factor]

graph pie factor [fw = factor] if primaria_privada != 8, over(primaria_privada) title("Condición de público/privada de" "la escuela PRIMARIA del entrevistado")
graph pie factor [fw = factor] if secundaria_privada != 8, over(secundaria_privada) title("Condición de público/privada de" "la escuela SECUNDARIA del entrevistado")
graph pie factor [fw = factor] if preparatoria_privada != 8, over(preparatoria_privada) title("Condición de público/privada de" "la escuela PREPARATORIA del entrevistado")
graph pie factor [fw = factor] if universidad_privada != 8, over(universidad_privada) title("Condición de público/privada de" "la UNIVERSIDAD del entrevistado")

graph pie factor [fw = factor], over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado")

graph pie factor [fw = factor] if sexo == 0, over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado - Hombres")
graph pie factor [fw = factor] if sexo == 1, over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado - Mujeres")

tabulate educacion_privada [fw = factor]

tabulate educacion_privada [fw = factor] if sexo == 0
tabulate educacion_privada [fw = factor] if sexo == 1

}

{
*Modelo logit para educación privada dada escolaridad de padres
logit educacion_privada pp_escolaridad [fw = factor]
margins, atmeans post

*Calculo de probabilidad con escolaridad de primaria, secundaria, bachillerato, universidad y posgrado

qui logit educacion_privada pp_escolaridad [fw = factor]
margins, at(pp_escolaridad = 6) atmeans post

qui logit educacion_privada pp_escolaridad [fw = factor]
margins, at(pp_escolaridad = 9) atmeans post

qui logit educacion_privada pp_escolaridad [fw = factor]
margins, at(pp_escolaridad = 12) atmeans post

qui logit educacion_privada pp_escolaridad [fw = factor]
margins, at(pp_escolaridad = 16) atmeans post

qui logit educacion_privada pp_escolaridad [fw = factor]
margins, at(pp_escolaridad = 18) atmeans post

*Cálculo de efectos marginales
qui logit educacion_privada pp_escolaridad [fw = factor]
margins, dydx(*) atmeans post
}

{
*Resumenes estadísticos de escolaridad de los padres
sum p_escolaridad [fw = factor]
hist p_escolaridad [fw = factor]

sum m_escolaridad [fw = factor]
hist m_escolaridad [fw = factor]

graph box p_escolaridad m_escolaridad [fw = factor]
scatter m_escolaridad p_escolaridad [fw = factor], msymbol(circle_hollow) msize(0.2) || lfit m_escolaridad p_escolaridad [fw = factor]
correlate m_escolaridad p_escolaridad [fw = factor]


*Exploración de correlación entre educación de los padres y del hijo
scatter escolaridad p_escolaridad [fw = factor], msymbol(circle_hollow) msize(0.2) || lfit escolaridad p_escolaridad
scatter escolaridad m_escolaridad [fw = factor], msymbol(circle_hollow) msize(0.2) mcolor("red") || lfit escolaridad m_escolaridad [fw = factor]

correlate p_escolaridad escolaridad [fw = factor]
correlate m_escolaridad escolaridad [fw = factor]



correlate pp_escolaridad escolaridad [fw = factor]
scatter pp_escolaridad escolaridad [fw = factor], msymbol(circle_hollow) msize(0.2) || lfit pp_escolaridad escolaridad [fw = factor]

reg escolaridad pp_escolaridad [fw = factor]
}

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




reg ln_ingresos_hogar ln_escolaridad i.sexo [fw = factor] if ln_ingresos_hogar != . & condicion_empleo == 1

**AQUI NOS QUEDAMOS, VAMOS A EXPLORAR LAS VARIABLES DE INGRESO (VER SI LAS DIVIDIMOS ENTRE EL NÚMERO DE PERSONAS QUE APORTAN EN EL HOGAR,
**Y VER SU RELACIÓN CON OTRAS VARIABLES**


*Exploración de las variables de ingreso


*Exploración de la relación entre las variables de ingreso y escolaridad y experiencia

*Correlaciones entre variables

}

{
**Aquí vamos a correr nuestra primer regresión de Mincer para explorar los retornos a la educación.
*Utilizamos como variables explicativas: escolaridad, experiencia y sexo



**Ahora vamos a incorporar la variable de educación privada

**Podemos incorporar también variables de educación de los padres


**Por ahí había una pregunta sobre dónde se ubicaba a sí mismo el hogar de origen del 1 al 10, puede servir aunque sea autopercibida
}

