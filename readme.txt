1- Se ingresa al portal con usuario y clave:
	siata.gov.co:8018/descarga_siata/index.php/index2/resultadosConsultaEstacionesAire/

2- Seleccionar "Estaciones Calidad de Aire" y se realiza una busqueda desde 1989 hasta la fecha de hoy
   con todas las estaciones seleccionadas, el resultado son muchas filas de información para descargar.
   En este punto se abre "google chrome developer tools" click derecho/Inspeccionar/Consola
   y en el cuadro de texto se escribe este javascript:

   document.querySelectorAll('a').forEach(function(me){if(me.href.indexOf('http://siata.gov.co:8018/descarga_siata') != -1 && me.href.indexOf('.csv') != -1) console.log(me.href)})

3- El resultado del paso 2 lo copie en el archivo (ssh/1-download-csv.sh):
   y se antepuso el comando the linux `curl -O` que descarga el archivo de internet
   para ejecutarlo se necesita abrir la consola de linux y ejecutarlo como un sh (shell scripting):
   >>$ sh 1-download-csv.sh
   Esto descarga todos los archivos al computador

4- Despues se creo una script de base de datos (3-mysqlimport.sh),los pasos fueron los siguientes "importante la ruta debe ser absulta o mysql falla":
   se abre la consola de linux y se ingresa al directorio donde estan los csv:
   >>$ ls -all
   luego con un editor de texto se antepone los comandos de mysql (El computador debe tener instalado mysql para poder hacer esto)
   y creada la base de datos "siata" y la tabla "estacion_data_calidadaire"
   mysql --local-infile -u root -p'password' -e "use siata;LOAD DATA LOCAL INFILE './estacion_data_calidadaire_11_20080401_20080430.csv' INTO TABLE estacion_data_calidadaire FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'"
   este archivo se guarda como sh y se ejecuta igual que el otro
   >>$ sh 3-mysqlimport.sh
   con esto queda una tabla de mas o menos un millon de filas

5- Una vez se revisa la info de esta tabla se puede notar que los datos quedaron mal ingresados y es porque los
   csv's tienen un problema de nombre de campos que se desplazan de izquierda a derecha los datos quedan mal
   para solcionar esto, primero se copia una fila como insert(query_1):

   >> INSERT INTO `estacion_data_calidadaire` (`codigoSerial`, `pm25`, `calidad_pm25`, `pm10`, `calidad_pm10`, `pm1`, `calidad_pm1`, `no`, `calidad_no`, `no2`, `calidad_no2`, `nox`, `calidad_nox`, `ozono`, `calidad_ozono`, `co`, `calidad_co`, `so2`, `calidad_so2`, `pst`, `calidad_pst`, `dviento_ssr`, `calidad_dviento_ssr`, `haire10_ssr`, `calidad_haire10_ssr`, `p_ssr`, `calidad_p_ssr`, `pliquida_ssr`, `calidad_pliquida_ssr`, `rglobal_ssr`, `calidad_rglobal_ssr`, `taire10_ssr`, `calidad_taire10_ssr`, `vviento_ssr`, `calidad_vviento_ssr`)
VALUES
	('0000-00-00 00:00:00', 'codigoSerial', 'pm25', 'calidad_pm25', 'pm10', 'calidad_pm10', 'pm1', 'calidad_pm1', 'no', 'calidad_no', 'no2', 'calidad_no2', 'nox', 'calidad_nox', 'ozono', 'calidad_ozono', 'co', 'calidad_co', 'so2', 'calidad_so2', 'pst', 'calidad_pst', 'dviento_ssr', 'calidad_dviento_ssr', 'haire10_ssr', 'calidad_haire10_ssr', 'p_ssr', 'calidad_p_ssr', 'pliquida_ssr', 'calidad_pliquida_ssr', 'rglobal_ssr', 'calidad_rglobal_ssr', 'taire10_ssr', 'calidad_taire10_ssr', 'vviento_ssr');

	depues se borran todas ls filas que tengan esos datos, ya que cada arhivo contiene el nombre de los campos:

	>> DELETE FROM estacion_data_calidadaire WHERE `pm25` = 'codigoSerial'

	luego se inserta solo una vez el "query_1"

   >> INSERT INTO `estacion_data_calidadaire` (`codigoSerial`, `pm25`, `calidad_pm25`, `pm10`, `calidad_pm10`, `pm1`, `calidad_pm1`, `no`, `calidad_no`, `no2`, `calidad_no2`, `nox`, `calidad_nox`, `ozono`, `calidad_ozono`, `co`, `calidad_co`, `so2`, `calidad_so2`, `pst`, `calidad_pst`, `dviento_ssr`, `calidad_dviento_ssr`, `haire10_ssr`, `calidad_haire10_ssr`, `p_ssr`, `calidad_p_ssr`, `pliquida_ssr`, `calidad_pliquida_ssr`, `rglobal_ssr`, `calidad_rglobal_ssr`, `taire10_ssr`, `calidad_taire10_ssr`, `vviento_ssr`, `calidad_vviento_ssr`)
VALUES
	('0000-00-00 00:00:00', 'codigoSerial', 'pm25', 'calidad_pm25', 'pm10', 'calidad_pm10', 'pm1', 'calidad_pm1', 'no', 'calidad_no', 'no2', 'calidad_no2', 'nox', 'calidad_nox', 'ozono', 'calidad_ozono', 'co', 'calidad_co', 'so2', 'calidad_so2', 'pst', 'calidad_pst', 'dviento_ssr', 'calidad_dviento_ssr', 'haire10_ssr', 'calidad_haire10_ssr', 'p_ssr', 'calidad_p_ssr', 'pliquida_ssr', 'calidad_pliquida_ssr', 'rglobal_ssr', 'calidad_rglobal_ssr', 'taire10_ssr', 'calidad_taire10_ssr', 'vviento_ssr');

	se ejecuta el select:

	>> SELECT * FROM estacion_data_calidadaire_test ORDER BY pm25 DESC;
	y se descarga en formato csv el resultado de este select, se le borra la primara linea que contiene los campos malos
	luego importe este csv en una nueva tabla algo como:
	fix_estacion_calidadaire

6- Para filtrar mas la informacion se ejecutaron select desde la suposición que el valor "-9999.0" es un error para el campo pm25 y pm10

	>> select * from `fix_estacion_calidadaire`
	WHERE `pm25` <> '-9999.0' AND `pm10` <> '-9999.0'

	Esta información se paso a otra tabla con el select:

	>>  INSERT INTO fix_estacion_calidadaire_filtrada
		select * from `fix_estacion_calidadaire`
		WHERE `pm25` <> '-9999.0' AND `pm10` <> '-9999.0'

7- Para graficar se realizaron los siguientes queries para cada año:

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2012-01-01 00:00:00' AND '2012-12-31 23:59:59'
	ORDER BY fecha

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2013-01-01 00:00:00' AND '2013-12-31 23:59:59'
	ORDER BY fecha

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2014-01-01 00:00:00' AND '2014-12-31 23:59:59'
	ORDER BY fecha

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2015-01-01 00:00:00' AND '2015-12-31 23:59:59'
	ORDER BY fecha

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2016-01-01 00:00:00' AND '2016-12-31 23:59:59'
	ORDER BY fecha

	>> SELECT fecha,
	IF(pm25 < '0', '0', pm25) pm25,
	IF(pm10 < '0', '0', pm10) pm10,
	IF(ozono < '0', '0', ozono) ozono,
	IF(nox < '0', '0', nox) nox
	FROM fix_estacion_calidadaire_filtrada
	WHERE fecha BETWEEN '2017-01-01 00:00:00' AND '2017-12-31 23:59:59'
	ORDER BY fecha

	El resultado son los siguintes google drives:

	(2012) https://drive.google.com/open?id=1lMRtTfS7ve6yRvWzCADQqeRzgzZIzdxo71om9tqr3Gc
	(2013) https://drive.google.com/open?id=1sr17OHmC1iwIdKxtLj-1BfbwxypgSBJ8_Otnbe289QQ
	(2014) https://drive.google.com/open?id=1Wi2V_tte1D7KJVfS6i1hCHWt8oiOKXos9lFYzzNTQVE
	(2015) https://drive.google.com/open?id=1bDbqA-y11_kdJVqwyPxiqOzL_dPIeAH3bEyZgGggpb8
	(2016) https://drive.google.com/open?id=1IGbuanbQsb3E3C4yqysXLVB-44yzcXBpYurnTfoEXJI
	(2017) https://drive.google.com/open?id=1gfUjOaFqwaf2o2-SFKYn1GUcKaoHPx8lJA1dasxan6U

8- Conclusiones.

	Al finalizar las graficas y ver que los valores de pm25 no sobrepasan el número "99.0"
	y sabemos que hemos llegado hasta 180, el select:
	>> select * from `fix_estacion_calidadaire`
	WHERE `pm25` <> '-9999.0' AND `pm10` <> '-9999.0'
	se puede mejorar para incluir mas información algo como:
	>> select * from `fix_estacion_calidadaire`
	WHERE `pm25` < '995' AND `pm25` > '0'
	ORDER BY fecha ASC;
	este devuelve 235354 filas, pero el pm25 no sobrepasan el número "99.0" que esta mal?

	Podemos ver muchos erroes en los datos tomados, datos como:

	"-9999.0"
	"-9964.0"
	"999999000.0"
	"999999.0"
	"995.0"

	Valores negativos para pm25 ?
	Se observa que los valores del nox solo son visibles apartir del 2017 antes no hay
	información relevante

9- Requirimientos:
	>> Mysql 5.6.x
	>> shell access
	>> manejo del lenguaje SQL de mysql
	>> manejo basico de shell scripting
	>> manejo de javascript
