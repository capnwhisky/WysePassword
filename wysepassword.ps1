<#
.SYNOPSIS
    Encodes or Decodes passwords for the Dell Wyse Terminals
.DESCRIPTION
    Takes a password string and encodes it to a Dell Wyse encoded password
    Takes a Dell Wyse encoded password and decodes it to a string
.EXAMPLE
    PS C:\> wysepassword.ps1 -Action Encode password
    Encodes the password into a Dell Wyse encoded password
    
    PS C:\> wysepassword.ps1 -Action Decode NFBBMHBBMDAJNOBP
    Decodes the encoded password into a human-readable string   
.INPUTS
    -Action Encode|Decode
    -Value {Password}
.OUTPUTS
    Returns the encoded or decoded value string
.NOTES
    Works for older Dell Wyse terminals
#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$Value,
    [Parameter(Mandatory=$false)]
    [ValidateSet("Encode","Decode")]
    [string]$Action = "Encode"
)
# Decoding Function
function NFuseDecode {
    Param(
        [string]$Value
    )
    $length = $Value.Length/2
    $arrReturn = [char[]]::new($length)
    for ($i=0; $i -lt $Length; $i++) {
        $a = $Value[$i*2]
        $a -= 1
        $a = $a -shl 4
        $a += $Value[$i*2+1]
        $a -= 0x41
        $arrReturn[$i] = $a
    }
    for ($i=$Length-1; $i -ge 0; $i--) {
        if ($i-1 -lt 0) {
            $a = 1024 # Shim
        } else {
            $a = $arrReturn[$i-1]
        }
        $a = $a -bxor $arrReturn[$i]
        $a = $a -bxor 0xA5
        $arrReturn[$i] = $a
    }
    return [System.String]::new($arrReturn,0,$arrReturn.Length)
}
# Encoding Function
function NFuseEncode {
    Param(
        [string]$Value
    )
    $length = $Value.Length
    $arrReturn = [char[]]::new($length*2)
    $arrTemp = [char[]]::new($length*2)

    for ($i=0; $i -lt $length; $i++) {
        $a = $Value[$i]
        $a = $a -bxor 0xA5
        $a = $a -bxor $arrTemp[$i-1]
        $arrTemp[$i] = $a
    }

    for ($i=0; $i -lt $length; $i++) {
        $y = $i*2
        $a = [int32]$arrTemp[$i]
        $b = [int32]$arrTemp[$i]
        $b = $b -band 0x0F
        $b += 0x41
        $a = $a -shr 4
        $a += 0x41
        $arrReturn[$y] = $a
        $arrReturn[$y+1] = $b
    }
    return [System.String]::new($arrReturn,0,$arrReturn.Length)
}

# Encode or Decode
switch($Action) {
    "Encode" { NFuseEncode($Value)}
    "Decode" { NFuseDecode($Value)}
}