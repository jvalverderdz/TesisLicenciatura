/*******************************************************************************
TESIS_C2_GraficasExploracionDatos.do
Author: Javier Valverde
Version: 1.1
Input:
	-Data/Exploration

Este Do genera las gráficas de datos de educación y mercados laborales para el
contexto empírico del Capítulo 2

Actualización:
La versión 1.1 incorpora la estandarización y sistematización de las roots y
paths

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


cd "$root/Capitulo 2/Data_C2/Raw"

gl graphs "$root/Capitulo 2/Data_C2/Graphs"
gl temp "$root/Capitulo 2/Data_C2/Temp"

*******************************************************************************
*********PARTE 1.1: Escolaridad, Cobertura y Analfabetismo (Nacional)**********


***1.1.1. Serie de tiempo de Escolaridad nacional
import delimited "Educacion/Informe/Escolaridad_Informe2020.csv", clear varn(1)
	rename (v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12) (esc2009 esc2010 esc2011 esc2012 esc2013 esc2014 esc2015 esc2016 esc2017 esc2018 esc2019)

	reshape long esc, i(entidad) j(year)
	rename esc escolaridad
	label variable escolaridad "Escolaridad"
	label variable year "Año"

	keep if entidad == "Nacional"
	format year %ty

	tsset year

	twoway (tsline escolaridad, yscale(range(7)) ytick(#5) ylabel(#5) legend(off) lwidth(medthick)) (scatter escolaridad year, mcolor(edkblue))
graph export "$graphs/111_Escolaridad_Nacional.png", replace


*_______________________________________________________________________________

***1.1.2. Serie de tiempo de alfabetización
import delimited "Educacion/Informe/Analfabetismo_Informe2020.csv", clear varn(1)
	rename (v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12) (entidad analf2009 analf2010 analf2011 analf2012 analf2013 analf2014 analf2015 analf2016 analf2017 analf2018 analf2019)

	reshape long analf, i(entidad) j(year)
	gen alf = 100 - analf

	label variable alf "Tasa de Alfabetización"
	label variable year "Año"


	keep if entidad == "Nacional"
	format year %ty

	tsset year

	twoway (tsline alf, yscale(range(90, 100)) ytick(#5) ylabel(#5) lcolor(edkblue) legend(off) lwidth(medthick)) (scatter alf year, mcolor(edkblue))
graph export "$graphs/112_Alfabetizacion_Nacional.png", replace


*_______________________________________________________________________________

***1.1.3. Barras agrupadas de Cobertura por niveles

	*Cobertura de básica
import delimited "Educacion/Informe/CoberturaBasica_Informe2020.csv", clear varn(1)
	rename (v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16) (cob_basica2005 cob_basica2006 cob_basica2007 cob_basica2008 cob_basica2009 cob_basica2010 cob_basica2011 cob_basica2012 cob_basica2013 cob_basica2014 cob_basica2015 cob_basica2016 cob_basica2017 cob_basica2018 cob_basica2019)

	reshape long cob_basica, i(entidad) j(year)

	label variable cob_basica "Educación Básica"
	label variable year "Año"

	keep if entidad == "Nacional"
	format year %ty
	tsset year 

save "$temp/cobertura_basica_nacional.dta", replace


	*Cobertura de media superior
import delimited "Educacion/Informe/CoberturaMediaSuperior_Informe2020.csv", clear varn(1)
	rename ïentidad entidad
	rename (v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16) (cob_ms2005 cob_ms2006 cob_ms2007 cob_ms2008 cob_ms2009 cob_ms2010 cob_ms2011 cob_ms2012 cob_ms2013 cob_ms2014 cob_ms2015 cob_ms2016 cob_ms2017 cob_ms2018 cob_ms2019)

	reshape long cob_ms, i(entidad) j(year)

	label variable cob_ms "Media Superior"
	label variable year "Año"

	keep if entidad == "Nacional"
	format year %ty
	tsset year 

save "$temp/cobertura_mediasuperior_nacional.dta", replace


	*Cobertura de superior
import delimited "Educacion/Informe/CoberturaSuperior_Informe2020.csv", clear varn(1)
	rename ïentidad entidad
	rename (v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16) (cob_sup2005 cob_sup2006 cob_sup2007 cob_sup2008 cob_sup2009 cob_sup2010 cob_sup2011 cob_sup2012 cob_sup2013 cob_sup2014 cob_sup2015 cob_sup2016 cob_sup2017 cob_sup2018 cob_sup2019)

	reshape long cob_sup, i(entidad) j(year)

	label variable cob_sup "Superior"
	label variable year "Año"

	keep if entidad == "Nacional"
	format year %ty
	tsset year 

save "$temp/cobertura_superior_nacional.dta", replace

	*Merge de coberturas
	use "$temp/cobertura_basica_nacional.dta", clear
	merge 1:1 year using "$temp/cobertura_mediasuperior_nacional.dta"
	drop _merge
	merge 1:1 year using "$temp/cobertura_superior_nacional.dta"


	twoway (tsline cob_basica cob_ms cob_sup, ytick(#5) ylabel(#5) lwidth(medthick medthick medthick) lcolor(1 edkblue) lcolor(2 emidblue) lcolor(3 eltblue) legend(order(1 2 3))) ///
		   (scatter cob_basica year, msymbol(O) mcolor(edkblue)) (scatter cob_ms year, msymbol(O) mcolor(emidblue)) (scatter cob_sup year, msymbol(T) mcolor(eltblue))
graph export "$graphs/113_Cobertura_Nacional.png", replace


*_______________________________________________________________________________

***1.1.4. Mapa de Escolaridad por Estado
import delimited "Educacion/Informe/Escolaridad_Informe2020.csv", clear varn(1)
	rename (v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12) (esc2009 esc2010 esc2011 esc2012 esc2013 esc2014 esc2015 esc2016 esc2017 esc2018 esc2019)

	reshape long esc, i(entidad) j(year)
	rename esc escolaridad
	label variable escolaridad "Escolaridad"
	label variable year "Año"
	replace entidad = "San Luis Potosi" if entidad == "San Luis PotosÃ­"
	
	drop if entidad == "Nacional"
	keep if year == 2019
	
	run "D:/Javier/Documents/ARCHIVO/gen_CVEGEO_Entidad.do"
	save "$temp/Escolaridad_entidades.dta", replace
	
	
	*Importar shapefile
	shp2dta using "C:/Mapa Digital 6/Proyecto basico de informacion/marco geoestadistico nacional 2010/estatal.shp", database(estatalDb) coordinates(estatalCo) genid(id) genc(c) replace
	use estatalDb, clear
	destring CVEGEO, replace
	capture keep CVEGEO NOM_ENT OID id x_c y_c
	
	merge 1:1 CVEGEO using "$temp/Escolaridad_entidades.dta"
	
	*Generar Mapa
	spmap esc using estatalCo, id(id) clmethod(q) clnumber(5) /// Definition of map
	ndlab("No Data") ndfcolor(gs13) /// Options for null data
	legend( pos() row(6) ring(0) size(*2) symx(*1.3) symy(*1) style(2) forcesize) legstyle(2) legorder(hilo) ///
	osize(vthin ..) fcolor(Blues2) // Style options

graph export "$graphs/114_Escolaridad_Entidades.png", width(1020) replace



*_______________________________________________________________________________

***1.1.5. Mapa de Analfabetismo por Estado
import delimited "Educacion/Informe/Analfabetismo_Informe2020.csv", clear varn(1)
	rename (v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12) (entidad analf2009 analf2010 analf2011 analf2012 analf2013 analf2014 analf2015 analf2016 analf2017 analf2018 analf2019)

	reshape long analf, i(entidad) j(year)
	label variable analf "Tasa de Analfabetismo"
	label variable year "Año"
	replace entidad = "San Luis Potosi" if entidad == "San Luis PotosÃ­"
	
	drop if entidad == "Nacional"
	keep if year == 2019
	
	run "D:/Javier/Documents/ARCHIVO/gen_CVEGEO_Entidad.do"
	save "$temp/Analfabetismo_entidades.dta", replace
	
	
	*Importar shapefile
	shp2dta using "C:/Mapa Digital 6/Proyecto basico de informacion/marco geoestadistico nacional 2010/estatal.shp", database(estatalDb) coordinates(estatalCo) genid(id) genc(c) replace
	use estatalDb, clear
	destring CVEGEO, replace
	capture keep CVEGEO NOM_ENT OID id x_c y_c
	
	merge 1:1 CVEGEO using "$temp/Analfabetismo_entidades.dta"
	
	*Generar Mapa
	spmap analf using estatalCo, id(id) clmethod(q) clnumber(5) /// Definition of map
	ndlab("No Data") ndfcolor(gs13) /// Options for null data
	legend( pos() row(6) ring(0) size(*2) symx(*1.3) symy(*1) style(2) forcesize) legstyle(2) legorder(hilo) ///
	osize(vthin ..) fcolor(Reds2) // Style options

graph export "$graphs/115_Analfabetismo_Entidades.png", width(1020) replace



*******************************************************************************
******************PARTE 1.2. APROVECHAMIENTO Y DESIGUALDAD **********************

*****Resultados PLANEA


***1.2.1. Resultados PLANEA por estado (Primaria)
import excel "PLANEA/PLANEA_PRIMARIA2018.xlsx", clear firstrow
	
	*tratar datos de resultados PLANEA
	keep if REPRESENTATIVO_LYC == "SI" & REPRESENTATIVO_MAT == "SI"
	drop if inlist(ENTIDAD, "CHIAPAS", "MICHOACAN", "OAXACA")
	save "$temp/planea_primaria18.dta", replace
	
	collapse (sum) LYC_LOGRO1 LYC_LOGRO2 LYC_LOGRO3 LYC_LOGRO4 MAT_LOGRO1 MAT_LOGRO2 MAT_LOGRO3 MAT_LOGRO4 (first) ENTIDAD, by(CVEGEO)
		
		gen LYC_TOTAL = LYC_LOGRO1 + LYC_LOGRO2 + LYC_LOGRO3 + LYC_LOGRO4
		gen MAT_TOTAL = MAT_LOGRO1 + MAT_LOGRO2 + MAT_LOGRO3 + MAT_LOGRO4
		
		gen share_LYC1 = (LYC_LOGRO1 / LYC_TOTAL)*100
		gen share_LYC2 = (LYC_LOGRO2 / LYC_TOTAL)*100
		gen share_LYC3 = (LYC_LOGRO3 / LYC_TOTAL)*100
		gen share_LYC4 = (LYC_LOGRO4 / LYC_TOTAL)*100
		gen share_MAT1 = (MAT_LOGRO1 / MAT_TOTAL)*100
		gen share_MAT2 = (MAT_LOGRO2 / MAT_TOTAL)*100
		gen share_MAT3 = (MAT_LOGRO3 / MAT_TOTAL)*100
		gen share_MAT4 = (MAT_LOGRO4 / MAT_TOTAL)*100
		
		format %9.3g share*
		replace ENTIDAD = proper(ENTIDAD)
		destring CVEGEO, replace
		
		*Generar Gráficas
		graph hbar share_LYC*, over(ENTIDAD, sort(share_LYC1) lab(angle(0) labsize(vsmall))) stack legend(order(1 "Insuficiente" 2 "Suficiente" 3 "Bueno" 4 "Destacado")) ///
			  note("Nota: Chiapas, Michoacán y Oaxaca no reportados por falta de representatividad en la aplicación", size(vsmall) al(right))
graph export "$graphs/121a_PLANEA18_Primarias_LYC.png", replace
		
		graph hbar share_MAT*, over(ENTIDAD, sort(share_MAT1) lab(angle(0) labsize(vsmall))) stack legend(order(1 "Insuficiente" 2 "Suficiente" 3 "Bueno" 4 "Destacado")) ///
			  note("Nota: Chiapas, Michoacán y Oaxaca no reportados por falta de representatividad en la aplicación", size(vsmall) al(right))
graph export "$graphs/121b_PLANEA18_Primarias_MAT.png", replace


*_______________________________________________________________________________

***1.2.2. Resultados PLANEA por estado (Secundaria)
import excel "PLANEA/PLANEA_SECUNDARIA2019.xlsx", clear firstrow
	
	*tratar datos de resultados PLANEA
	keep if REPRESENTATIVO_LYC == "SÍ" & REPRESENTATIVO_MAT == "SÍ"
	drop if inlist(ENTIDAD, "Chiapas", "Michoacán", "Oaxaca", "Tlaxcala")
	destring LYC* MAT*, replace
	save "$temp/planea_secundaria19.dta", replace
	
	collapse (sum) LYC_LOGRO1 LYC_LOGRO2 LYC_LOGRO3 LYC_LOGRO4 MAT_LOGRO1 MAT_LOGRO2 MAT_LOGRO3 MAT_LOGRO4 (first) ENTIDAD, by(CVEGEO)
		
		gen LYC_TOTAL = LYC_LOGRO1 + LYC_LOGRO2 + LYC_LOGRO3 + LYC_LOGRO4
		gen MAT_TOTAL = MAT_LOGRO1 + MAT_LOGRO2 + MAT_LOGRO3 + MAT_LOGRO4
		
		gen share_LYC1 = (LYC_LOGRO1 / LYC_TOTAL)*100
		gen share_LYC2 = (LYC_LOGRO2 / LYC_TOTAL)*100
		gen share_LYC3 = (LYC_LOGRO3 / LYC_TOTAL)*100
		gen share_LYC4 = (LYC_LOGRO4 / LYC_TOTAL)*100
		gen share_MAT1 = (MAT_LOGRO1 / MAT_TOTAL)*100
		gen share_MAT2 = (MAT_LOGRO2 / MAT_TOTAL)*100
		gen share_MAT3 = (MAT_LOGRO3 / MAT_TOTAL)*100
		gen share_MAT4 = (MAT_LOGRO4 / MAT_TOTAL)*100
		
		format %9.3g share*
		destring CVEGEO, replace
		
		*Generar Gráficas
		graph hbar share_LYC*, over(ENTIDAD, sort(share_LYC1) lab(angle(0) labsize(vsmall))) stack legend(order(1 "Insuficiente" 2 "Suficiente" 3 "Bueno" 4 "Destacado")) ///
			  note("Nota: Chiapas, Michoacán, Oaxaca y Tlaxcala no reportados por falta de representatividad en la aplicación", size(vsmall) al(right))
graph export "$graphs/122a_PLANEA19_Secundarias_LYC.png", replace
		
		graph hbar share_MAT*, over(ENTIDAD, sort(share_MAT1) lab(angle(0) labsize(vsmall))) stack legend(order(1 "Insuficiente" 2 "Suficiente" 3 "Bueno" 4 "Destacado")) ///
			  note("Nota: Chiapas, Michoacán, Oaxaca y Tlaxcala no reportados por falta de representatividad en la aplicación", size(vsmall) al(right))
graph export "$graphs/122b_PLANEA19_Secundarias_MAT.png", replace



*_____________________________________________________
***1.2.3. Mapa/tabla Resultados PLANEA por estado (Media Superior)
import excel "PLANEA/PLANEA_MEDIASUPERIOR2017.xlsx", clear firstrow
	
	*tratar datos de resultados PLANEA
	keep if REPRESENTATIVO_LYC == "SI" & REPRESENTATIVO_MAT == "SI"
	save "$temp/planea_mediasuperior17.dta.", replace
	
	collapse (sum) LYC_LOGRO1 LYC_LOGRO2 LYC_LOGRO3 LYC_LOGRO4 MAT_LOGRO1 MAT_LOGRO2 MAT_LOGRO3 MAT_LOGRO4 (first) ENTIDAD, by(CVEGEO)
		gen LYC_ALTO = LYC_LOGRO3 + LYC_LOGRO4
		gen LYC_BAJO = LYC_LOGRO1 + LYC_LOGRO2
		gen MAT_ALTO = MAT_LOGRO3 + MAT_LOGRO4
		gen MAT_BAJO = MAT_LOGRO1 + MAT_LOGRO2
		gen LYC_TOTAL = LYC_LOGRO1 + LYC_LOGRO2 + LYC_LOGRO3 + LYC_LOGRO4
		gen MAT_TOTAL = MAT_LOGRO1 + MAT_LOGRO2 + MAT_LOGRO3 + MAT_LOGRO4
		
		gen share_LYC1 = (LYC_LOGRO1 / LYC_TOTAL)*100
		gen share_LYC2 = (LYC_LOGRO2 / LYC_TOTAL)*100
		gen share_LYC3 = (LYC_LOGRO3 / LYC_TOTAL)*100
		gen share_LYC4 = (LYC_LOGRO4 / LYC_TOTAL)*100
		gen share_MAT1 = (MAT_LOGRO1 / MAT_TOTAL)*100
		gen share_MAT2 = (MAT_LOGRO2 / MAT_TOTAL)*100
		gen share_MAT3 = (MAT_LOGRO3 / MAT_TOTAL)*100
		gen share_MAT4 = (MAT_LOGRO4 / MAT_TOTAL)*100
		
		gen share_LYC_ALTO = (LYC_ALTO / LYC_TOTAL)*100
		gen share_LYC_BAJO = (LYC_BAJO / LYC_TOTAL)*100
		gen share_MAT_ALTO = (MAT_ALTO / MAT_TOTAL)*100
		gen share_MAT_BAJO = (MAT_BAJO / MAT_TOTAL)*100
		
		format %9.3g share*
		destring CVEGEO, replace
		
save "$temp/PLANEA_mediasuperior.dta", replace
	
	*Importar shapefile
	shp2dta using "C:/Mapa Digital 6/Proyecto basico de informacion/marco geoestadistico nacional 2010/estatal.shp", database(estatalDb) coordinates(estatalCo) genid(id) genc(c) replace
use estatalDb, clear
	destring CVEGEO, replace
	capture keep CVEGEO NOM_ENT OID id x_c y_c
	
	merge 1:1 CVEGEO using "$temp/PLANEA_mediasuperior.dta"
	
	*Generar Mapa de Porcentaje de Buenos/Destacados (Secundaria)
	spmap share_LYC_ALTO using estatalCo, id(id) clmethod(q) clnumber(5) /// Definition of map
	ndlab("Sin Datos") ndfcolor(gs13) /// Options for null data
	legend( pos() row(6) ring(0) size(*2) symx(*1.3) symy(*1) style(2) forcesize) legstyle(2) legorder(hilo) ///
	osize(vthin ..) fcolor(Blues2) // Style options

graph export "$graphs/123a_PLANEA_MediaSuperior_BuenosDestacados_LYC.png", width(1020) replace
	
	*Generar Mapa de Porcentaje de Bajos (Secundaria)
	spmap share_MAT_ALTO using estatalCo, id(id) clmethod(q) clnumber(5) /// Definition of map
	ndlab("Sin Datos") ndfcolor(gs13) /// Options for null data
	legend( pos() row(6) ring(0) size(*2) symx(*1.3) symy(*1) style(2) forcesize) legstyle(2) legorder(hilo) ///
	osize(vthin ..) fcolor(Blues2) // Style options
graph export "$graphs/123b_PLANEA_MediaSuperior_BuenosDestacados_MAT.png", width(1020) replace


*_____________________________________________________

***1.2.4. Resultados PLANEA por subsistema
use "$temp/planea_primaria18.dta", clear

	collapse (sum) LYC_LOGRO1 LYC_LOGRO2 LYC_LOGRO3 LYC_LOGRO4 MAT_LOGRO1 MAT_LOGRO2 MAT_LOGRO3 MAT_LOGRO4 , by(SUBSISTEMA)

		gen LYC_TOTAL = LYC_LOGRO1 + LYC_LOGRO2 + LYC_LOGRO3 + LYC_LOGRO4
		gen MAT_TOTAL = MAT_LOGRO1 + MAT_LOGRO2 + MAT_LOGRO3 + MAT_LOGRO4
		
		gen share_LYC1 = (LYC_LOGRO1 / LYC_TOTAL)*100
		gen share_LYC2 = (LYC_LOGRO2 / LYC_TOTAL)*100
		gen share_LYC3 = (LYC_LOGRO3 / LYC_TOTAL)*100
		gen share_LYC4 = (LYC_LOGRO4 / LYC_TOTAL)*100
		gen share_MAT1 = (MAT_LOGRO1 / MAT_TOTAL)*100
		gen share_MAT2 = (MAT_LOGRO2 / MAT_TOTAL)*100
		gen share_MAT3 = (MAT_LOGRO3 / MAT_TOTAL)*100
		gen share_MAT4 = (MAT_LOGRO4 / MAT_TOTAL)*100
		format %9.1g share*

	sort share_LYC1 share_MAT1
asdoc list SUBSISTEMA share_LYC1 share_LYC2 share_LYC3 share_LYC4 share_MAT1 share_MAT2 share_MAT3 share_MAT4, save(tablas.doc) replace
	

*_____________________________________________________
	
***1.2.4. Resultados PLANEA por marginacion
use "$temp/planea_primaria18.dta", clear

	collapse (sum) LYC_LOGRO1 LYC_LOGRO2 LYC_LOGRO3 LYC_LOGRO4 MAT_LOGRO1 MAT_LOGRO2 MAT_LOGRO3 MAT_LOGRO4 , by(GRADO_MARGINACION)
				gen LYC_TOTAL = LYC_LOGRO1 + LYC_LOGRO2 + LYC_LOGRO3 + LYC_LOGRO4
		gen MAT_TOTAL = MAT_LOGRO1 + MAT_LOGRO2 + MAT_LOGRO3 + MAT_LOGRO4
		
		gen share_LYC1 = (LYC_LOGRO1 / LYC_TOTAL)*100
		gen share_LYC2 = (LYC_LOGRO2 / LYC_TOTAL)*100
		gen share_LYC3 = (LYC_LOGRO3 / LYC_TOTAL)*100
		gen share_LYC4 = (LYC_LOGRO4 / LYC_TOTAL)*100
		gen share_MAT1 = (MAT_LOGRO1 / MAT_TOTAL)*100
		gen share_MAT2 = (MAT_LOGRO2 / MAT_TOTAL)*100
		gen share_MAT3 = (MAT_LOGRO3 / MAT_TOTAL)*100
		gen share_MAT4 = (MAT_LOGRO4 / MAT_TOTAL)*100
		format %9.1g share*

	sort share_LYC1 share_MAT1
	list GRADO_MARGINACION share_LYC1 share_LYC2 share_LYC3 share_LYC4 share_MAT1 share_MAT2 share_MAT3 share_MAT4
asdoc list GRADO_MARGINACION share_LYC1 share_LYC2 share_LYC3 share_LYC4 share_MAT1 share_MAT2 share_MAT3 share_MAT4, save(tablas.doc) append
	

***1.2.5. Resultados ENLACE por estudios de los padres
import delimited "PLANEA/planea_primaria_nivelespadres.csv", clear
rename ïpadre padre
label variable padre "Nivel educativo de los padres"

graph bar l1 l2 l3 l4, over(nivel, sort(l1) lab(angle(90) labsize(vsmall))) by(padre, note("")) stack legend(order(1 "Insuficiente" 2 "Suficiente" 3 "Bueno" 4 "Destacado"))
graph export "$graphs/124_PLANEA_EscolaridadPadres.png", width(1020) replace

***

