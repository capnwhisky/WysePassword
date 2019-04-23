
/* 
    Javascript code to encode or decode a Dell Wyse password
    Reverse engineering by David Lodge

    Converted to Javascript by Ryan Maloney

    Usage: var EncodedPassword = NFuseEncode("password")
           var DecodedPassword = NFuseDecode("NFBBMHBBMDAJNOBP") 
*/
// Encode function
// Input: String
// Returns: String
function NFuseEncode(Value){
    var Length = Value.length;
    var arrReturn = new Array(Length);
    var arrTemp = new Array(Length);
    for (let i=0; i<Length; i++) {
        let a,b,y
        a = Value.charAt(i).charCodeAt();
        a ^= 0xA5;
        a ^= arrTemp[i-1];
        arrTemp[i] = a;
        y = i*2;
        b = a;
        b &= 0x0F;
        b += 0x41;
        a >>= 4;
        a += 0x41;
        arrReturn[y] = String.fromCharCode(a);
        arrReturn[y+1] = String.fromCharCode(b);
    }
    return arrReturn.join("");
}
// Decode function
// Input: String
// Returns: String
function NFuseDecode(Value){
    var Length = Value.length/2;
    var arrReturn = new Array(Length);
    for (let i=0; i<Length; i++) {
        let a = Value.charAt(i*2).charCodeAt();
        a -= 1;
        a <<= 4;
        a += Value.charAt(i*2+1).charCodeAt();
        a -= 0x41;
        arrReturn[i] = a;  
    }
    for (let i=Length-1; i>=0; i--) {
        let a = (arrReturn[i-1] === undefined)?1024:arrReturn[i-1];
        a ^= arrReturn[i];
        a ^= 0xA5;
        arrReturn[i] = String.fromCharCode(a);
    }
    return arrReturn.join("");
}