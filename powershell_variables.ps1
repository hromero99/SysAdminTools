
$current_directory_library = @{}

if ($args.count -ne 1){
  Write-Output "Usage: ./script.ps1 file.txt"
  Exit
}
<#
Leemos el contenido del fichero project-includes, el formato es clave=valor
La clave $folder_to_link[0] sera el nombre de la variabla de entorno usada en visual studio
El valor $folder_to_link[1] sera el valor de dicha variable de entorno
#>

# Eliminamos .\ que por defecto es agregado en la linea de comandos de powershell
$file_include  = $($args[0]).replace(".\","")

foreach ($line in Get-Content "$(pwd)\$file_include"){
  $folder_to_link =  $line.split("=")
  $current_directory_library[$folder_to_link[0]] = $folder_to_link[1]
}

# Comprobamos que los directorios que van a ser seteados en las variables de entorno existan
foreach ($library_folder_name in $current_directory_library.Keys){

  $folder_to_link = $current_directory_library.$library_folder_name
  $final_folder = "$(pwd)\$folder_to_link"

    Write-Output $final_folder
  if (Test-Path $final_folder){
    Write-Output "Estableciendo variable de entorno $library_folder_name con el valor $final_folder"
    #Establecer variable de entorno
    [Environment]::SetEnvironmentVariable($library_folder_name, $final_folder)
  }
}
