#Solicitar al usuario que ingrese una fecha
#El input del tpa va con 2 ceros y el inputos del STLD va con 3 ceros para la POS
#Hacer condicional para las pos al momento de elgir

function ComparacionDePOS {

#Solictante de informacion
$fecha = Read-Host "Ingrese una fecha en el formato dd/MM/yyyy que desea buscar"


#Cargo ruta del archivo pos-db en variable
$ruta_xml = "D:\newpos61\posdata\pos-db_WAYSTATION.xml"
$ruta_stld = "D:\newpos61\POSFILES\stld\$fecha\STLD.xml"
#$ruta_stld2 = "D:\newpos61\POSFILES\stld\$fecha"
if(Test-Path -Path $ruta_xml){
	$xml =  New-Object System.Xml.XmlDocument
	$xml.Load($ruta_xml)
}else{
	Write-Host " "
	Write-Host "Error : No se encontro el XML de la Waystation en el path " -ForegroundColor Red
	Write-Host " "
	return
}
if(Test-Path -Path $ruta_stld){
	$xml2 = (get-content -path $ruta_stld)
$xml2 -replace "#END#","" | out-file C:\STLD.xml
$xml2 = [xml] (get-content -path C:\STLD.xml)

}else{
	if (!(Test-Path (Split-Path $ruta_stld))){
				
	Write-Host " "
	Write-Host "La carpeta para el archivo STLD.xml no se encontró en la ruta especificada: $($ruta_stld | Split-Path).Verificar si la misma se Renombro o no se genero." -ForegroundColor Red
	Write-Host " "
    return
}
	else{
	Write-Host " "
	
	Write-Host "Se encontro la carpeta $fecha pero no se encontró el STLD en la misma. Verificar si este se esta Regenerando." -ForegroundColor Red
	Write-Host " "
    return
	
	
}
}


$members = $xml.UsedService.member
$memberCount = 0
$used_service= $xml.SelectSingleNode("//UsedService[@serviceType='POS']")
$nodesCount = 0
Write-Host "POS en POS-DB:"
Write-Host " "
foreach ($member in $used_service.ChildNodes) {
	Write-Host "POS00$($member.GetAttribute('name'))"
	 $memberCount++
}
Write-Host " Numero de POS : $memberCount"
Write-Host " "
Write-Host "POS en STLD:"
Write-Host " "

foreach ($Node in $xml2.TLD.Node){		
		$Node.id
		$nodesCount++
}

Write-Host " "
Write-Host "Numero de POS:  $nodesCount"
Write-Host " "
#Comparando los conteos de nodos "member" y "id"
#Write-Host $memberCount
#Write-Host $nodesCount
 
if ($memberCount -eq $nodesCount) {
    Write-Host "Cantidad de pos del STLD coinciden con las del local"
	} elseif ($memberCount -lt $nodesCount) {
    Write-Host "La cantidad de POS en el archivo pos-db_WAYSTATION.xml es menor que la cantidad de POS en el archivo STLD.xml"
} else {
    Write-Host "La cantidad de POS en el archivo STLD.xml es menor que la cantidad de POS en el archivo pos-db_WAYSTATION.xml"
}
function ComparacionDeVentas{
	$fecha = Read-Host "Ingrese una fecha en el formato dd/MM/yyyy que desea buscar"
	
	$pos= Read-Host "Ingrese POS(POS00XX) "
	$pos_fecha = $pos + "_" + $fecha
	$ruta_stld = "D:\newpos61\POSFILES\stld\$fecha\STLD.xml"
	if(Test-Path -Path $ruta_stld){
		$xml2 = (get-content -path $ruta_stld)
		$xml2 -replace "#END#","" | out-file C:\STLD.xml
		$xml2 = [xml] (get-content -path C:\STLD.xml)

	}else{
		if (!(Test-Path (Split-Path $ruta_stld))){
				
	Write-Host " "
	Write-Host "La carpeta para el archivo STLD.xml no se encontró en la ruta especificada: $($ruta_stld | Split-Path).Verificar si la misma se Renombro o no se genero." -ForegroundColor Red
	Write-Host " "
    return
}
	else{
	Write-Host " "
	
	Write-Host "Se encontro la carpeta $fecha pero no se encontró el STLD en la misma. Verificar si este se esta Regenerando." -ForegroundColor Red
	Write-Host " "
    return
	
}
}
	$ruta_tpa = "D:\newpos61\POSFILES\LOGS\tlog\$pos\$pos_fecha.tpa"
	$ruta_tpa_error = "D:\newpos61\POSFILES\LOGS\tlog\$pos\$pos_fecha.tpa.error"
	
	if (Test-Path -Path $ruta_tpa) {
    $tpa = $ruta_tpa
	Write-Host "Archivo TPA normal encontrado para comparacion"
}else {
    # Si el archivo tpa no está en la ruta especificada, buscar uno con extensión .tpa.ERROR
    if (Test-Path -Path $ruta_tpa_error) {
        $tpa = $ruta_tpa_error
		Write-Host "No se encontro el tpa normal, comparacion realizada con TPA.ERROR"
    }
    else {
        # Si no se encuentra el archivo tpa ni el archivo .tpa.ERROR, mostrar un mensaje de error
        Write-Host "Error: No se encontró el archivo tpa para la POS $pos y la fecha $fecha.Revisar dentro de la misma $pos si posee tpa y pasarlo a waystation" -ForegroundColor Red
        return
    }
}

	
	
	
	
	#$xml2 = (get-content -path $ruta_stld)
	#$xml2 -replace "#END#","" | out-file C:\STLD.xml
	#$xml2 = [xml] (get-content -path C:\STLD.xml)

	
    	[int]$ventas_stld = 0
	[int]$ventas_stldTotales = 0
	#$tpa = $ruta_tpa 
	$ventas_tpa = (Get-Content -Path $tpa | Select-String -Pattern 'salestatus="128"').Count
	#$ventas_tpa = (Select-String -Path $tpa -Pattern 'salestatus="128"' -AllMatches).Matches.Count
	$Node = $xml2.TLD.Node | ? {$_.id -eq $pos}
	if ($Node) {
    $ventas_stld = 0
    $vacios_stld = 0
    $Node.id
       $Node.Event.TRX_Sale | ? {$_.status -eq "Paid"} | % {$ventas_stld ++}
    $Node.Event.TRX_Sale | ? {$_.status -eq "Voided"} | % {$vacios ++}
    write-host "Paid: " $ventas_stld
    write-host "Voided: " $vacios_stld
    write-host " "
}
else {
    write-host "No se encontró el nodo con el ID $pos_stld"
}
$xml2.TLD.Node.Event.TRX_Sale | ? {$_.status -eq "Paid"} | % {$ventas_stldTotales ++}
write-host "Total de Ventas Local: " $ventas_stldTotales
write-host " "
	if( $ventas_stld -eq $ventas_tpa){
		write-host "Ventas Coincidentes entre TPA y STLD "
		write-host "Ventas STLD $ventas_stld "
		write-host "Ventas TPA $ventas_tpa "
		
		
	} else{
		write-host "NO Coinciden Ventas "
		write-host " "
		write-host "Ventas STLD $ventas_stld "
		write-host "Ventas TPA $ventas_tpa "
	}

}
function VentasSTLD{
	
	
$fecha = Read-Host "Ingrese una fecha en el formato dd/MM/yyyy que desea buscar"

$ruta_stld = "D:\newpos61\POSFILES\stld\$fecha\STLD.xml"
	if(Test-Path -Path $ruta_stld){
	$xml2 = (get-content -path $ruta_stld)
$xml2 -replace "#END#","" | out-file C:\STLD.xml
$xml2 = [xml] (get-content -path C:\STLD.xml)

}else{
	if (!(Test-Path (Split-Path $ruta_stld))){
				
	Write-Host " "
	Write-Host "La carpeta para el archivo STLD.xml no se encontró en la ruta especificada: $($ruta_stld | Split-Path).Verificar si la misma se Renombro o no se genero." -ForegroundColor Red
	Write-Host " "
    return
}
	else{
	Write-Host " "
	
	Write-Host "Se encontro la carpeta $fecha pero no se encontró el STLD en la misma. Verificar si este se esta Regenerando." -ForegroundColor Red
	Write-Host " "
    return
	
}
}
	
	#$xml2 = (get-content -path $ruta_stld)
	#$xml2 -replace "#END#","" | out-file C:\STLD.xml
	#$xml2 = [xml] (get-content -path C:\STLD.xml)
[int]$ventas = 0
[int]$ventasTotales = 0
write-host " "
write-host "RESULTADOS:  "
write-host " "
#Por cada Node en el archivo doc
foreach ($Node in $xml2.TLD.Node) {
	$ventas = 0
    $vacios = 0
	$Node.id																#Imprimo en pantalla el id=POS00XX
	$Node.Event | ? {$_.Type -eq "TRX_DayOpen"}  | % {"TRX_DayOpen"}		#Cuando encuentre en el evento TRX_DayOpen imprime en pantalla
	$Node.Event | ? {$_.Type -eq "TRX_DayClose"} | % {"TRX_DayClose"}		#Cuando encuentre en el evento TRX_DayClose imprime en pantalla
	$Node.Event.TRX_Sale | ? {$_.status -eq "Paid"} | % {$ventas ++}		#Cuenta los eventos "TRX_Sale Type="Paid" del nodo
	$Node.Event.TRX_Sale | ? {$_.status -eq "Voided"} | % {$vacios ++}		#Cuenta los eventos "TRX_Sale Type="Paid" del nodo
	write-host "Paid: " $ventas												#Imprimo en pantalla las ventas del nodo
    write-host "Voided: " $vacios
	write-host " "
} 
$xml2.TLD.Node.Event.TRX_Sale | ? {$_.status -eq "Paid"} | % {$ventasTotales ++}			#Cuenta los eventos "TRX_Sale Type="Paid" del documento
write-host "Total de Ventas: " $ventasTotales												#Imprimo en pantalla el total de ventas del día de negocio
write-host "Fecha: " $xml2.TLD.businessDate
write-host " "
}
do {
    Write-Host "---- Menú de opciones ----"
    Write-Host "1. Comparar cantidad de pos STLD con las del Local'"
    Write-Host "2. Comparacion de Ventas"
    Write-Host "3. Informacion de Ventas STLD"
    Write-Host "4. Salir"
    $option = Read-Host "Ingrese una opción (1-4)"
    switch ($option) {
        "1" {
            ComparacionDePOS
        }
        "2" {
            ComparacionDeVentas
        }
        "3" {
            VentasSTLD
        }
        "4" {
            break
        }
        default {
            Write-Host "Opción inválida. Intente nuevamente."
        }
    }
} while ($option -ne "4")