---
external help file: SCOMBlackOut-help.xml
Module Name: SCOMBlackOut
online version:
schema: 2.0.0
---

# log-activity

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

```
log-activity [[-logDateFormat] <DateTime>] [[-logFile] <String>] [-entryType] <String> [-logMessage] <String>
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -entryType
Classify Entry

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Information, Error, Success

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -logDateFormat
Date of Log Entry

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -logFile
Name of logfile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -logMessage
Log Message

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.DateTime
System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
