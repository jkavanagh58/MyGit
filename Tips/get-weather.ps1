Function get-weather {
    <#
        .SYNOPSIS
            Retrieves current weather information.
        .DESCRIPTION
            Uses the OpenWeatherMap web service to retrieve the current weather information for a location
            by ZipCode. This function requires an API key which you can obtain from the Link provided.
        .PARAMETER apiZipCode
            Mandatory parameter to retrieve the weather data for a specific city. You can also call
        .PARAMETER apiKey
            Enter the API key you have received from openweather.org
        .LINK
            http://openweathermap.org/appid
        .NOTES
            ===========================================================================
            Created with:	Visual Studio Code
            Created on:		01.09.2018
            Created by:		Kavanagh, John J.
            Organization:	TEKSystems
            ===========================================================================
            02.12.2018 JJK:	DONE: provide input for Zip Code
            02.19.2018 JJK: TODO:Determine why multiple records for description are returned.
    #>
    Param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage = "Zip code for weather data")]
        [Alias("ZipCode")]
        [System.String]$apiZipCode,
        [String]$apiKey = "getyourownkey"
    )
        Try {
            $getWeatherdata = Invoke-WebRequest "api.openweathermap.org/data/2.5/weather?zip=$apiZipCode,us&APPID=$apiKey&units=imperial&mode=json"
            $weather = ConvertFrom-Json $getWeatherdata.Content
            if ($weather.weather.description.count -gt 1){
                "Current temperature is {0} with {1}" -f $weather.main.temp, $weather.weather.description[0]
            }
            Else {
                "Current temperature is {0} with {1}" -f $weather.main.temp, $weather.weather.description
            }
        }
        Catch {
            Write-Output "Unable to query weather data"
            $error[0].Exception.Message
        }
}