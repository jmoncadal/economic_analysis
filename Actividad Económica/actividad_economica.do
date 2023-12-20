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

drop year month periodo
order id concepto fecha var_ISE

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
rename C concepto

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























