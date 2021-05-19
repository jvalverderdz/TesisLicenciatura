/*******************************************************************************
TESIS_C3_Estimaciones.do
Author: Javier Valverde
Version: 1.0
Input:
	-emovi17.dta

Este Do realiza las estimaciones de los modelos lineales OLS y Ologit para encontrar
la relación y los efectos entre escolaridad e ingresos y las interacciones con
la riqueza del hogar de origen


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

gl raw "$root/Capitulo 3/Data_C3/Raw"
gl graphs "$root/Capitulo 3/Data_C3/Graphs"
gl temp "$root/Capitulo 3/Data_C3/Temp"

*Importación de la base
use "$raw/emovi17.dta", clear
drop if ingresos_hogar == 0



*=======================MODELO OLS====================================
reg ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada [fw = factor]


*=======================MODELO OLOGIT====================================
ologit ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada [fw = factor]

*Prueba Brant de proportional odds
ologit ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada
brant



*=======================MODELO GOLOGIT====================================

gologit2 ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada [fw = factor], npl(c.ln_escolaridad)
estimates store gologit_m1

gologit2 ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada [fw = factor], npl(c.ln_escolaridad) or

*Probabilidades medias
estimates restore gologit_m1
margins, atmeans post


*=======================EFECTOS MARGINALES====================================

*Efectos marginales de la escolaridad
estimates restore gologit_m1
margins, dydx(ln_escolaridad) atmeans post

*Efectos marginales del decil de origen
estimates restore gologit_m1
margins, dydx(decil_origen) atmeans post

*Efectos marginales de la experiencia
estimates restore gologit_m1
margins, dydx(ln_experiencia) atmeans post

*Efectos marginales de la experiencia al cuadrado
estimates restore gologit_m1
margins, dydx(ln_experiencia2) atmeans post

*Efectos marginales de la educacion privada
estimates restore gologit_m1
margins, dydx(i.educacion_privada) atmeans post


*Efectos marginales de la escolaridad para cada decil de origen
cls
forval i = 1/10 {
	estimates restore gologit_m1
	margins , dydx(ln_escolaridad) at(decil_origen=`i') atmeans post
	*est store margins`i'
}


*Efecto marginal de la educación privada para cada nivel del decil de origen
cls
forval i = 1/10 {
	estimates restore gologit_m1
	margins, dydx(i.educacion_privada) at(decil_origen=`i') atmeans post
}


*=======================PROBABILIDADES ESTIMADAS====================================

*Probabilidades de ingresos bajos por nivel de educación
putexcel set "$root/Capitulo 3/Efectos Marginales.xlsx", sheet("P Estimadas") modify

cls
matrix P_b = J(10, 5, 0)
forval y = 1/3 {
	di "***Trabajando para Nivel de Ingreso `y'***"
	forval i = 1/10 {
		di "**Trabajando para Decil `i'**"
		local k = 1
		foreach j in 6 9 12 16 {
			di "Trabajando para nivel educativo `j'"
			estimates restore gologit_m1
			margins, predict(outcome(`y')) at(decil_origen = `i' c.ln_escolaridad= `=ln(`j')') atmeans post
			matrix P_b[`i',`k'] = P_b[`i',`k'] + e(b)
			local k = `k' + 1
		}
	}
}
putexcel B2 = matrix(P_b)


*Probabilidades de ingresos medios por nivel de educación
cls
matrix P_m = J(10, 5, 0)
forval y = 4/5 {
	di "***Trabajando para Nivel de Ingreso `y'***"
	forval i = 1/10 {
		di "**Trabajando para Decil `i'**"
		local k = 1
		foreach j in 6 9 12 16 {
			di "Trabajando para nivel educativo `j'"
			estimates restore gologit_m1
			margins, predict(outcome(`y')) at(decil_origen = `i' c.ln_escolaridad= `=ln(`j')') atmeans post
			matrix P_m[`i',`k'] = P_m[`i', `k'] + e(b)
			local k = `k' + 1
		}
	}
}
putexcel B14 = matrix(P_m)


*Probabilidades de ingresos altos por nivel de educación
cls
matrix P_a = J(10, 5, 0)
forval y = 6/7 {
	di "***Trabajando para Nivel de Ingreso `y'***"
	forval i = 1/10 {
		di "**Trabajando para Decil `i'**"
		local k = 1
		foreach j in 6 9 12 16 {
			di "Trabajando para nivel educativo `j'"
			estimates restore gologit_m1
			margins, predict(outcome(`y')) at(decil_origen = `i' c.ln_escolaridad= `=ln(`j')') atmeans post
			matrix P_a[`i',`k'] = P_a[`i', `k'] + e(b)
			local k = `k' + 1
		}
	}
}
putexcel B26 = matrix(P_a)


***Estimación de probabilidades de ciertos escenarios***

*Escenario A: Persona poco educada, con poca experiencia y escuela pública
cls
matrix EA = J(10,7,0)
di "***Trabajando para Escenario A"
forval i = 1/10 {
	di "Trabajando para Decil `i'"
	estimates restore gologit_m1
	margins, at(decil_origen =`i' c.ln_escolaridad= `=ln(6)' ln_experiencia= `=ln(2)' ln_experiencia2= `=ln(2^2)' educacion_privada = 0) atmeans post
	matrix P_hat = e(b)
	forval j = 1/7 {
		matrix EA[`i',`j'] = P_hat[1,`j']
	}
}

*Escenario B: Persona con educación media superior, algo de experiencia y educación pública
cls
matrix EB = J(10,7,0)
di "***Trabajando para Escenario B"
forval i = 1/10 {
	di "Trabajando para Decil `i'"
	estimates restore gologit_m1
	margins, at(decil_origen =`i' c.ln_escolaridad= `=ln(12)' ln_experiencia= `=ln(5)' ln_experiencia2= `=ln(5^2)' educacion_privada = 0) atmeans post
	matrix P_hat = e(b)
	forval j = 1/7 {
		matrix EB[`i',`j'] = P_hat[1,`j']
	}
}

*Escenario C: Persona con educación superior, mucha experiencia y educación privada
cls
matrix EC = J(10,7,0)
di "***Trabajando para Escenario C"
forval i = 1/10 {
	di "Trabajando para Decil `i'"
	estimates restore gologit_m1
	margins, at(decil_origen =`i' c.ln_escolaridad= `=ln(16)' ln_experiencia= `=ln(15)' ln_experiencia2= `=ln(15^2)' educacion_privada = 1) atmeans post
	matrix P_hat = e(b)
	forval j = 1/7 {
		matrix EC[`i',`j'] = P_hat[1,`j']
	}
}

*Exportamos resultados de Escenarios
putexcel set "$root/Capitulo 3/Efectos Marginales.xlsx", sheet("Escenarios") modify
putexcel B2 = matrix(EA)
putexcel B14 = matrix(EB)
putexcel B26 = matrix(EC)




*=======================GOODNESS OF FITTING====================================
foreach var in 1 2 3 4 5 6 7 {
	qui gologit2 ingresos_hogar c.ln_escolaridad##c.decil_origen ln_experiencia ln_experiencia2 i.educacion_privada [fw = factor]
	predict x`var', pr outcome(#`var')
}

gen xmax = x1
gen hat = 1
foreach var in 2 3 4 5 6 7 {
	replace hat = `var' if x`var' > xmax
	replace xmax = x`var' if x`var' > xmax
}

gen ingresos_hat = .
replace ingresos_hat = 1 if hat == 1
replace ingresos_hat = 2 if hat == 2
replace ingresos_hat = 3 if hat == 3
replace ingresos_hat = 4 if hat == 4
replace ingresos_hat = 5 if hat == 5
replace ingresos_hat = 6 if hat == 6
replace ingresos_hat = 7 if hat == 7

gen check = factor if ingresos_hat == ingresos_hogar
egen N = sum(factor)
egen N_check = sum(check)

gen R = N_check / N
sum R

tab ingresos_hogar ingresos_hat [fw = factor]


*marginsplot
