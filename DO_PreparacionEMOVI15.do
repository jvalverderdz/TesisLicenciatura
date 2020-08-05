*Preparación de la base de datos de la EMOVI 2017 para su exploración

cls
clear
*Importación de la base
use "D:\Javier\Documents\Tesis\Databases Tesis\EMOVI\EMOVI 2015\emovi2015_adultos.dta", clear

{
*Renombrar variables relevantes
rename p4 edad
rename p9 nivel
rename p10 grado

rename p35 edad_dejo_estudiar

rename p44 situacion_laboral
rename p45 autoempleado
rename p50isco ocupacionisco
rename p55 horas_trabajo
rename p56 antiguedad
rename p63 salario_mensual
rename p64 salario_rangos

rename p89 autoadscripcion_ho

rename p88a8 p_nivel
rename p88b8 m_nivel


gen experiencia = edad - edad_dejo_estudiar

gen sexo = .
replace sexo = 0 if p3 == 1
replace sexo = 1 if p3 == 2

}

{
*========================ESCOLARIDAD DEL ENTREVISTADO============================
*Crear variable de años de escolaridad basada en el nivel de escolaridad

gen escolaridad = .
replace escolaridad = 0 if nivel == 2
replace escolaridad = 6 if nivel == 3 | nivel == 4
replace escolaridad = 9 if nivel == 5 | nivel == 6 | nivel == 8
replace escolaridad = 12 if nivel == 7 | nivel == 9 | nivel == 10
replace escolaridad = 16 if nivel == 11
replace escolaridad = 0 if nivel == 97 | nivel == 1 | nivel == 99

*Reducir los años de escolaridad en caso de no haber tenido el certificado, y ajustar
*por únicamente los años que cursó
replace escolaridad = escolaridad + grado if grado != 99
replace escolaridad = 21 if escolaridad >= 21



*Exploración de características de la educación del entrevistado (privada o pública)	
gen escuela_privada = .
replace escuela_privada = 0 if p11 == 1
replace escuela_privada = 1 if p11 == 2
}



*=======================ESCOLARIDAD DE LOS PADRES====================================
{
gen p_escolaridad = .
replace p_escolaridad = 6 if p_nivel == 2
replace p_escolaridad = 9 if p_nivel == 3 | p_nivel == 4
replace p_escolaridad = 12 if p_nivel == 5 | p_nivel == 6 | p_nivel == 8
replace p_escolaridad = 16 if p_nivel == 7 | p_nivel == 9 | p_nivel == 10
replace p_escolaridad = 18 if p_nivel == 11
replace p_escolaridad = 0 if p_nivel == 97 | p_nivel == 1

gen m_escolaridad = .
replace m_escolaridad = 0 if m_nivel == 2
replace m_escolaridad = 6 if m_nivel == 3 | m_nivel == 4
replace m_escolaridad = 9 if m_nivel == 5 | m_nivel == 6 | m_nivel == 8
replace m_escolaridad = 12 if m_nivel == 7 | m_nivel == 9 | m_nivel == 10
replace m_escolaridad = 16 if m_nivel == 11
replace m_escolaridad = 0 if m_nivel == 97 | m_nivel == 1


gen pp_escolaridad = .
replace pp_escolaridad = (m_escolaridad + p_escolaridad)/2 if p_escolaridad != . & m_escolaridad != .
replace pp_escolaridad = m_escolaridad if p_escolaridad == . & m_escolaridad != .
replace pp_escolaridad = p_escolaridad if m_escolaridad == . & p_escolaridad != .
//Generamos una variable de escolaridad promedio de padres (de todos modos como están correlacionadas va a dar algo parecido

}


{
*=======================INGRESO========================================
gen ocupado = 0
replace ocupado = 1 if situacion_laboral == 1
replace ocupado = 1 if autoempleado == 1

replace salario_mensual = 0 if salario_mensual == 97
replace salario_mensual = . if salario_mensual == 99

replace salario_mensual = 2103/2 if salario_mensual == . & salario_rangos == 1
replace salario_mensual = (2104+4206)/2 if salario_mensual == . & salario_rangos == 2
replace salario_mensual = (4207+6309)/2 if salario_mensual == . & salario_rangos == 3
replace salario_mensual = (6310+10515)/2 if salario_mensual == . & salario_rangos == 4
replace salario_mensual = (10516+21030)/2 if salario_mensual == . & salario_rangos == 5
replace salario_mensual = (21031+42060)/2 if salario_mensual == . & salario_rangos == 6
replace salario_mensual = (42061+63090)/2 if salario_mensual == . & salario_rangos == 7
replace salario_mensual = (63091+105150)/2 if salario_mensual == . & salario_rangos == 8
replace salario_mensual = (105150)/2 if salario_mensual == . & salario_rangos == 8


replace horas_trabajo = . if horas_trabajo == 999
gen ingreso_horas = salario_mensual / (horas_trabajo*4) if salario_mensual != . & horas_trabajo != .
replace ingreso_horas = salario_mensual / 160 if horas_trabajo == .

}


*=============================================================

*====EXPLORACIÓN DE DATOS==================================0


*Regresiones preliminares
reg ingreso_horas escolaridad experiencia i.sexo [fw = weight]
reg salario_mensual escolaridad experiencia i.sexo [fw = weight]
reg salario_mensual escolaridad i.sexo [fw = weight]
reg ingreso_horas escolaridad i.sexo [fw = weight]
reg ingreso_horas escolaridad [fw = weight]

gen ln_ingreso_horas = ln(ingreso_horas)
gen ln_salario_mensual = ln(salario_mensual)
gen ln_escolaridad = ln(escolaridad)
gen ln_experiencia = ln(experiencia)



reg ln_ingreso_horas ln_escolaridad ln_experiencia i.sexo [fw = weight]
reg ln_salario_mensual ln_escolaridad ln_experiencia i.sexo [fw = weight]

scatter ln_ingreso_horas ln_escolaridad [fw = weight]

scatter ingreso_horas escolaridad [fw = weight] if ingreso_horas < 500, msymbol(circle_hollow) msize(0.2) || lfit ingreso_horas escolaridad [fw = weight]

scatter salario_mensual escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit ingreso_horas escolaridad [fw = weight]






{
*Resumenes estadístico de la escolaridad
sum escolaridad [fw = weight]
sum escolaridad [fw = weight], detail

sum escolaridad [fw = weight] if sexo == 1
sum escolaridad [fw = weight] if sexo == 2

graph box escolaridad [fw = weight], by(sexo)

hist escolaridad [fw = weight], by(sexo) bin(10)
}

{
*Resumenes estadísticos de la escolaridad según condición de la escuela (privada o pública)

hist primaria_privada [fw = weight]

graph pie factor [fw = weight] if primaria_privada != 8, over(primaria_privada) title("Condición de público/privada de" "la escuela PRIMARIA del entrevistado")
graph pie factor [fw = weight] if secundaria_privada != 8, over(secundaria_privada) title("Condición de público/privada de" "la escuela SECUNDARIA del entrevistado")
graph pie factor [fw = weight] if preparatoria_privada != 8, over(preparatoria_privada) title("Condición de público/privada de" "la escuela PREPARATORIA del entrevistado")
graph pie factor [fw = weight] if universidad_privada != 8, over(universidad_privada) title("Condición de público/privada de" "la UNIVERSIDAD del entrevistado")

graph pie factor [fw = weight], over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado")

graph pie factor [fw = weight] if sexo == 0, over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado - Hombres")
graph pie factor [fw = weight] if sexo == 1, over(educacion_privada) title("Condición de público/privada de" "la escuela de la escolaridad máxima del entrvevistado - Mujeres")

tabulate educacion_privada [fw = weight]

tabulate educacion_privada [fw = weight] if sexo == 0
tabulate educacion_privada [fw = weight] if sexo == 1

}

{
*Modelo logit para educación privada dada escolaridad de padres
logit educacion_privada pp_escolaridad [fw = weight]
margins, atmeans post

*Calculo de probabilidad con escolaridad de primaria, secundaria, bachillerato, universidad y posgrado

qui logit educacion_privada pp_escolaridad [fw = weight]
margins, at(pp_escolaridad = 6) atmeans post

qui logit educacion_privada pp_escolaridad [fw = weight]
margins, at(pp_escolaridad = 9) atmeans post

qui logit educacion_privada pp_escolaridad [fw = weight]
margins, at(pp_escolaridad = 12) atmeans post

qui logit educacion_privada pp_escolaridad [fw = weight]
margins, at(pp_escolaridad = 16) atmeans post

qui logit educacion_privada pp_escolaridad [fw = weight]
margins, at(pp_escolaridad = 18) atmeans post

*Cálculo de efectos marginales
qui logit educacion_privada pp_escolaridad [fw = weight]
margins, dydx(*) atmeans post
}

{
*Resumenes estadísticos de escolaridad de los padres
sum p_escolaridad [fw = weight]
hist p_escolaridad [fw = weight]

sum m_escolaridad [fw = weight]
hist m_escolaridad [fw = weight]

graph box p_escolaridad m_escolaridad [fw = weight]
scatter m_escolaridad p_escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit m_escolaridad p_escolaridad [fw = weight]
correlate m_escolaridad p_escolaridad [fw = weight]


*Exploración de correlación entre educación de los padres y del hijo
scatter escolaridad p_escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit escolaridad p_escolaridad
scatter escolaridad m_escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) mcolor("red") || lfit escolaridad m_escolaridad [fw = weight]

correlate p_escolaridad escolaridad [fw = weight]
correlate m_escolaridad escolaridad [fw = weight]



correlate pp_escolaridad escolaridad [fw = weight]
scatter pp_escolaridad escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit pp_escolaridad escolaridad [fw = weight]

reg escolaridad pp_escolaridad [fw = weight]
}

{
*Exploración de las variables de ingreso
sum ingresos_hogar [fw = weight] if condicion_empleo == 1
hist ingresos_hogar [fw = weight] if ingresos_hogar != 0 & condicion_empleo == 1

scatter ingresos_hogar escolaridad [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar escolaridad [fw = weight] if condicion_empleo == 1

correlate ingresos_hogar escolaridad experiencia [fw = weight] if condicion_empleo == 1 & ingresos_hogar != .

scatter ingresos_hogar experiencia [fw = weight], msymbol(circle_hollow) msize(0.2) || lfit ingresos_hogar experiencia [fw = weight] if condicion_empleo == 1

gen ln_ingresos_hogar = ln(ingresos_hogar)
gen ln_escolaridad = ln(escolaridad)
gen ln_experiencia = ln(experiencia)

reg ln_ingresos_hogar ln_escolaridad ln_experiencia i.sexo [fw = weight] if ln_ingresos_hogar != . & condicion_empleo == 1

predict ln_u1, resid
hist ln_u1, norm

reg ingresos_hogar escolaridad experiencia i.sexo [fw = weight] if ingresos_hogar != . & condicion_empleo == 1
predict u1, resid
hist u1, norm




reg ln_ingresos_hogar ln_escolaridad i.sexo [fw = weight] if ln_ingresos_hogar != . & condicion_empleo == 1

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

