cls
clear all
set more off
cap log close 

global dir "C:\Users\Juan\Desktop\Programación\Proyectos\Data Analysis\Actividad Económica"
cd "${dir}"

**# ISE ------------------------------------------------------------------------

import excel "raw_data/ISE.xlsx", sheet("Cuadro 1") cellrange("A44:HS57") ///
								  firstrow clear

** Limpieza de la base de datos 
drop B-M
rename Concepto concepto
gen id = _n
order id

** Tratamiento de la base de datos
reshape long m_, i(id) j(periodo)
rename m_ var_ISE
order id concepto periodo var_ISE

tostring periodo, replace
gen year = substr(periodo, 1, 4)
gen month = substr(periodo, 5, 5)

destring year, replace
destring month, replace

gen fecha = ym(year, month)
format fecha %tm

gen fechaq = qofd(dofm(ym(year, month)))
format fechaq %tq

drop year month periodo
order id concepto fecha var_ISE

save "clean_data/ise", replace

** Graficando series de tiempo

* Variación ISE Total
preserve
	keep if id == 13

	tsset fecha
	#d;
		tsline var_ISE, lcolor(navy) xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE", replace);
	#d cr;
	
	#d;
		tsline var_ISE if tin(2020m1, 2023m12), lcolor(navy)
						xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISEs_2023", replace);
	#d cr;
restore

* Variación ISE Actividades Primarias

preserve
	keep if id == 1

	tsset fecha
	#d;
		tsline var_ISE, lcolor(navy) xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_primarias", replace);
	#d cr;
	
	#d;
		tsline var_ISE if tin(2020m1, 2023m12), lcolor(navy)
						xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_primarias_2023", replace);
	#d cr;
restore

* Variación ISE Actividades Secundarias

preserve
	keep if id == 3
	tsset fecha
	
	#d;
		tsline var_ISE, lcolor(cranberry) xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_secundarias", replace);
	
	#d cr;
	
	#d;
		tsline var_ISE if tin(2020m1, 2023m12), lcolor(cranberry)
						xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_secundarias_2023", replace);
	#d cr;
	
restore


* Variación ISE Actividades Terciarias
preserve
	keep if id == 5
	tsset fecha
	
	#d;
		tsline var_ISE, lcolor(dkgreen) xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_terciarias", replace);
	#d cr;

	#d;
		tsline var_ISE if tin(2020m1, 2023m12), lcolor(green)
						xtitle("Fecha") ytitle("Variación ISE")
						yline(0) name("vISE_act_secundarias_2023", replace);
	#d cr;

restore

**# PIB ------------------------------------------------------------------------

import excel "raw_data/PIB.xlsx", sheet("Cuadro 1") cellrange("C48:BZ63") ///
								 firstrow clear
								 
* Limpieza de la base de datos

drop D-G

* Tratamiento de la base de datos
gen id = _n

reshape long m_, i(id) j(periodo)
order id concepto periodo
rename m_ var_PIB

tostring periodo, replace

gen quarter = substr(periodo, 1, 1)
gen year = substr(periodo, 2, 5)

destring quarter, replace
destring year, replace

gen fecha = yq(year, quarter)
format fecha %tq

drop periodo quarter year
order id concepto fecha

save "clean_data/pib", replace

* PIB Total

preserve

	keep if id == 15
	tsset fecha

	#d;
		tsline var_PIB, lcolor(navy) xtitle("Trimestre") ytitle("Variación (%)")
						yline(0) name("pib_total", replace);
	
		tsline var_PIB if tin(2020q1, 2023q4), lcolor(navy) xtitle("Trimestre")
		ytitle("Variación (%)")	yline(0) name("pib_total_2020", replace);		
	
	#d cr;
	
restore


* Comparación entre el PIB y el ISE - Serie histórica

use "${dir}/clean_data/ise", replace
keep if id == 13

collapse (mean) var_ISE, by(fechaq)
rename fechaq fecha

tempfile ise
save `ise' 

use "${dir}/clean_data/pib", replace

keep if id == 15
	
merge 1:1 fecha using `ise'
keep if _merge == 3

tsset fecha

#d ;
	tw (tsline var_PIB, lcolor(navy))
	   (tsline var_ISE, lcolor(cranberry) yline(0)
	   ),
	   xtitle("Trimestre")
	   ytitle("Variación (%)")
	   legend(label(1 "PIB") label(2 "ISE"))
	   name("varpib_varise", replace)  
	   ;
	   
#d cr;

* PIB por componente

use "${dir}/clean_data/pib", replace

encode concepto, gen(concepto_cat)
label list concepto_cat
drop id concepto 
reshape wide var_PIB, i(fecha) j(concepto_cat)

tsset fecha

#d;
tw (tsline var_PIB15, lcolor(navy) lpattern(dash))
   (tsline var_PIB8, lcolor(cranberry))
   (tsline var_PIB11, lcolor(stc3)),
   yline(0)
   name("pib_componentens", replace);
#d cr;

**# IPC -----------------------------------------------------------------------

import excel "${dir}/raw_data/inflacion.xlsx", sheet("Sheet1") cellrange("A8:E379") firstrow clear 

#d;
rename (AñoaaaaMesmm Inflacióntotal1 Límiteinferior Metadeinflación Limitesuperior)
	   (fecha inflacion l_inferior meta l_superior);
#d cr;

tostring fecha, replace	
gen year = substr(fecha, 1, 4)
gen month = substr(fecha, 5, 6)

destring year, replace
destring month, replace

drop fecha

gen fecha = ym(year, month)
format fecha %tm

drop year month
order fecha

tsset fecha 

#d ;
tw (tsline inflacion, lcolor(navy) xtitle("Fecha") ytitle("Inflación (%)")
					  legend(pos(6) col(4)))
   (tsline l_inferior, lcolor(red))
   (tsline l_superior, lcolor(dkgreen))
   (tsline meta, lcolor(gold)
   name("inflacion", replace)),
   legen(label(1 "Inflación") label(2 "Límite inferior")
		 label(3 "Límite superior") label(4 "Meta"));

#d cr;

drop if missing(l_inferior)
gen aciertos = (inflacion > l_inferior) & (inflacion < l_superior) 
tab aciertos

di (119/251)*100

















