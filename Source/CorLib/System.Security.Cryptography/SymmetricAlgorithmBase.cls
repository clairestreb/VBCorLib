VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SymmetricAlgorithmBase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2012 Kelly Ethridge
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
'PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
'FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
'DEALINGS IN THE SOFTWARE.
'
'
' Module: SymmetricAlgorithmBase
'

''
' Provides a common base of functionality for <a href="SymmetricAlgorithm.html">SymmetricAlgorithm</a> derived classes.
'
' @remarks The base class implements many of the details necessary for implementing
' a Symmetric Cryptographic Algorithm. By utilizing the base class the implementor
' can quickly provide a new implementation that is consistent with the existing
' implementations without the need to manage lower level details.
' @see SymmetricAlgorithm
Option Explicit

''
' Used for implementations that must check for some kind of weak or semi-weak key.
'
' @param RgbKey The key to be checked for weakness.
' @param Ex The exception indicating the key is weak and should be thrown.
' @remarks If the <i>RgbKey</i> is considered weak by the current symmetric algorithm, it should set <i>Ex</i>
' to an appropriate <a href="Exception.html">Exception</a> object. Typically a <a href="CryptographicException.html">CryptographicException</a> is set.
Public Event CheckForWeakKey(ByRef RgbKey() As Byte, ByRef Ex As Exception)

Private mLegalBlockSizes()  As KeySizes
Private mBlockSize          As Long
Private mLegalKeySizes()    As KeySizes
Private mKeySize            As Long
Private mFeedbackSize       As Long
Private mMode               As CipherMode
Private mPadding            As PaddingMode
Private mIV()               As Byte
Private mKey()              As Byte



''
' Adds a new <a href="KeySizes.html">KeySizes</a> object with the specified values to the list of legal block sizes.
'
' @param MinSize The mininum block size in bits the algorithm can process.
' @param MaxSize The maximum block size in bits the algorithm can process.
' @param SkipSize The number of bits the block size can change from minimum to maximum.
' @remarks A derived class uses this to add the set of legal block sizes the implementing algorithm can process.
' <p>As an example, the <a href="RijndaelManaged.html">RijndaelManaged</a> class calls this method in <b>Class_Initialize</b>.
' <pre>
' mBase.AddLegalBlockSize 128, 256, 64
' </pre>
Public Sub AddLegalBlockSize(ByVal MinSize As Long, ByVal MaxSize As Long, ByVal SkipSize As Long)
    AddKeySize mLegalBlockSizes, MinSize, MaxSize, SkipSize
End Sub

''
' Returns a list of legal block sizes.
'
' @return Returns an array of KeySize objects containing all the legal block sizes.
'
Public Property Get LegalBlockSizes() As KeySizes()
    LegalBlockSizes = mLegalBlockSizes
End Property

''
' Returns the currently set block size in bits.
'
' @return The currently block size in bits.
'
Public Property Get BlockSize() As Long
    BlockSize = mBlockSize
End Property

''
' Sets the current block size to be used.
'
' @param Value The new current block size to be used.
' @remarks The block size is in bits and must be one of the legal block sizes.
'
Public Property Let BlockSize(ByVal Value As Long)
    If Not IsLegalSize(mLegalBlockSizes, Value) Then _
        Error.Cryptographic Cryptography_InvalidBlockSize
    
    mBlockSize = Value
    Erase mIV
End Property

''
' Adds a new <a href="KeySizes.html">KeySizes</a> object with the supplied values to the list of legal key sizes.
'
' @param MinSize The mininum key size in bits the algorithm can use.
' @param MaxSize The maximum key size in bits the algorithm can use.
' @param SkipSize The number of bits used to step from the minimum to maximum key size. All
' intermediate sizes are also legal sizes.
' @remarks A derived class uses this to add the set of legal block sizes the implementing algorithm can process.
' <p>As an example, the <a href="RijndaelManaged.html">RijndaelManaged</a> class calls this method in <b>Class_Initialize</b>.
' <pre>
' mBase.AddLegalKeySize 128, 256, 64
' </pre>
Public Sub AddLegalKeySize(ByVal MinSize As Long, ByVal MaxSize As Long, ByVal SkipSize As Long)
    AddKeySize mLegalKeySizes, MinSize, MaxSize, SkipSize
End Sub

''
' Returns a list of legal key sizes.
'
' @return An array of KeySize objects containing all the legal key sizes in bits.
'
Public Property Get LegalKeySizes() As KeySizes()
    LegalKeySizes = mLegalKeySizes
End Property

''
' Returns the currently set key size to be used.
'
' @return The currently set key size in bits to be used.
'
Public Property Get KeySize() As Long
    KeySize = mKeySize
End Property

''
' Sets the new key size value to be used.
'
' @param Value The new key size in bits.
' @remarks The new value must be of a legal size.
'
Public Property Let KeySize(ByVal Value As Long)
    If Not IsLegalSize(mLegalKeySizes, Value) Then _
        Error.Cryptographic Cryptography_InvalidKeySize
    
    mKeySize = Value
    Erase mKey
End Property

''
' Returns the current feedback size in bits.
'
' @return The current feedback size in bits.
'
Public Property Get FeedbackSize() As Long
    FeedbackSize = mFeedbackSize
End Property

''
' Sets the current feedback size in bits to be used.
'
' @param Value The new feedback size.
' @remarks The feedback size must be greater than zero and evenly divisible by 8.
' The size cannot be greater than the current block size.
'
Public Property Let FeedbackSize(ByVal Value As Long)
    If (Value <= 0) Or (Value > mBlockSize) Or (Value Mod 8 <> 0) Then _
        Error.Cryptographic Cryptography_InvalidFeedbackSize
    
    mFeedbackSize = Value
End Property

''
' Returns the current cipher mode to be used.
'
' @return The current cipher mode to be used.
' @see CipherMode
'
Public Property Get Mode() As CipherMode
    Mode = mMode
End Property

''
' Sets the cipher mode to be used.
'
' @param Value The new cipher mode.
' @see CipherMode
'
Public Property Let Mode(ByVal Value As CipherMode)
    Select Case Value
        Case CipherMode.CBC, CipherMode.ECB, CipherMode.OFB, CipherMode.CFB
            mMode = Value
        Case Else
            Error.Cryptographic Cryptography_InvalidCipherMode
    End Select
End Property

''
' Returns the current padding to be used.
'
' @return The currnet padding.
' @see PaddingMode
'
Public Property Get Padding() As PaddingMode
    Padding = mPadding
End Property

''
' Sets the padding mode to be used.
'
' @param Value The new padding mode to be used.
' @see PaddingMode
'
Public Property Let Padding(ByVal Value As PaddingMode)
    Select Case Value
        Case PaddingMode.None, PaddingMode.ANSIX923, PaddingMode.ISO10126, PaddingMode.PKCS7, PaddingMode.Zeros
            mPadding = Value
        Case Else
            Error.Cryptographic Cryptography_InvalidPaddingMode
    End Select
End Property

''
' Returns the current IV value.
'
' @return The current IV value.
' @remarks If no IV has been set, then a random IV will be generated.
'
Public Function GetIV() As Byte()
    If CorArray.IsNull(mIV) Then
        GenerateIV
    End If
    
    GetIV = mIV
End Function

''
' Sets the current IV value.
'
' @param RgbIV The new IV value.
' @remarks The bit length of the IV value must equal the block size.
'
Public Sub SetIV(ByRef RgbIV() As Byte)
    Dim Size As Long
    Size = CorArray.Length(RgbIV)
    
    If (Size * 8) <> mBlockSize Then _
        Error.Cryptographic Cryptography_InvalidIVSize
    
    ' We do this to support non-zero based arrays.
    ReDim mIV(0 To Size - 1)
    Buffer.BlockCopy RgbIV, 0, mIV, 0, Size
End Sub

''
' Generates a random IV value.
'
Public Sub GenerateIV()
    mIV = CryptoHelper.GetRandomBytes(mBlockSize \ 8)
End Sub

''
' Returns the current secret key.
'
' @return The current secret key is returned.
' @remarks If no key has been set, then a random key will be generated.
'
Public Function GetKey() As Byte()
    If CorArray.IsNull(mKey) Then
        GenerateKey
    End If
    
    GetKey = mKey
End Function

''
' Sets the current secret key.
'
' @param RgbKey The new secret key.
' @remarks The bit length of the new value must be of a legal key size.
'
Public Sub SetKey(ByRef RgbKey() As Byte)
    If SAPtr(RgbKey) = vbNullPtr Then _
        Error.ArgumentNull "Key", ArgumentNull_Array
        
    Dim Size As Long
    
    Size = Len1D(RgbKey)
    
    If Not ValidKeySize(Size * 8) Then _
        Error.Argument Cryptography_InvalidKeySize, "Key"
    
    OnCheckForWeakKey RgbKey
    
    ' We do this so we have a zero-based key array.
    ReDim mKey(0 To Size - 1)
    Buffer.BlockCopy RgbKey, 0, mKey, 0, Size
    mKeySize = Size * 8
End Sub

''
' Generates a new random key.
'
' @remarks The "CheckForWeakKey" event is raised.
'
Public Sub GenerateKey()
    Dim Ex As Exception
    
    ReDim mKey(0 To mKeySize \ 8 - 1)
    
    Do
        CryptoHelper.FillRandomBytes mKey
        Set Ex = Nothing
        RaiseEvent CheckForWeakKey(mKey, Ex)
    Loop While Not Ex Is Nothing
End Sub

''
' Clears the IV and Key values.
'
Public Sub Clear()
    Erase mIV
    Erase mKey
End Sub

''
' Checks if a bit length is a valid key size in bits.
'
' @param BitLength The value to check.
' @return Returns True if the value is a valid key size, False otherwise.
'
Public Function ValidKeySize(ByVal BitLength As Long) As Boolean
    ValidKeySize = IsLegalSize(mLegalKeySizes, BitLength)
End Function

''
' Returns a clone of a key.
'
' @param RgbKey The key to return the clone of.
' @return The newly cloned key.
' @remarks If a missing parameter is passed in, then the key from the GetKey function will be returned.
' <p>The cloned key will be zero-based regardless of the base of the passed in key array.</p>
' <p>If a key is passed in, then the "CheckForWeakKey" event will be raised.</p>
'
Public Function CloneRgbKey(ByRef RgbKey As Variant) As Byte()
    If IsMissing(RgbKey) Then
        ' We know keys from our property are valid, so just exit.
        CloneRgbKey = Me.GetKey
        Exit Function
    End If
    
    If VarType(RgbKey) <> vbByteArray Then _
        Error.Argument Argument_ByteArrayRequired, "Key"
    If CorArray.IsNull(RgbKey) Then _
        Error.Cryptographic Cryptography_InvalidKeySize
        
    Dim Size        As Long
    Dim Result()    As Byte
    
    Size = Len1D(RgbKey)
    
    If Not IsLegalSize(mLegalKeySizes, Size * 8) Then _
        Error.Cryptographic Cryptography_InvalidKeySize
    
    ReDim Result(0 To Size - 1)
    Buffer.BlockCopy RgbKey, 0, Result, 0, Size
    OnCheckForWeakKey Result
    CloneRgbKey = Result
End Function

''
' Returns a clone of an IV.
'
' @param RgbIV The IV to return a clone of.
' @return The newly cloned IV.
' @remarks If a missing parameter is passed in, then the IV from the GetIV function will be returned.
' <p>The cloned IV will be zero-based regardless of the base of the passed in IV array.</p>
'
Public Function CloneRgbIV(ByRef RgbIV As Variant) As Byte()
    If IsMissing(RgbIV) Then
        CloneRgbIV = Me.GetIV
        Exit Function
    End If
    
    If VarType(RgbIV) <> vbByteArray Then _
        Error.Argument Argument_ByteArrayRequired, "RgbIV"
    
    Dim Result()    As Byte
    Dim Size        As Long
    
    If CorArray.IsNull(RgbIV) Then
        Result = CryptoHelper.GetRandomBytes(mBlockSize \ 8)
    Else
        Size = CorArray.Length(RgbIV)
        
        If (Size * 8) <> mBlockSize Then _
            Error.Cryptographic Cryptography_InvalidIVSize
        
        ReDim Result(0 To Size - 1)
        Buffer.BlockCopy RgbIV, 0, Result, 0, Size
    End If
    
    CloneRgbIV = Result
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Helpers
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub IncrementKeySizeCapacity(ByRef Arr() As KeySizes)
    If SAPtr(Arr) = vbNullPtr Then
        ReDim Arr(0)
    Else
        ReDim Preserve Arr(UBound(Arr) + 1)
    End If
End Sub

Private Sub AddKeySize(ByRef Arr() As KeySizes, ByVal MinSize As Long, ByVal MaxSize As Long, ByVal SkipSize As Long)
    IncrementKeySizeCapacity Arr
    Set Arr(UBound(Arr)) = Cor.NewKeySizes(MinSize, MaxSize, SkipSize)
End Sub

Private Function IsLegalSize(ByRef LegalSizes() As KeySizes, ByVal BitLength As Long) As Boolean
    If SAPtr(LegalSizes) = vbNullPtr Then
        IsLegalSize = True
        Exit Function
    End If
    
    Dim i As Long
    For i = 0 To UBound(LegalSizes)
        If LegalSizes(i).IsLegalSize(BitLength) Then
            IsLegalSize = True
            Exit Function
        End If
    Next i
End Function

Private Sub OnCheckForWeakKey(ByRef Key() As Byte)
    Dim Ex As Exception
    
    RaiseEvent CheckForWeakKey(Key, Ex)
    
    If Not Ex Is Nothing Then
        Throw Ex
    End If
End Sub


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Constructors
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
    mMode = CipherMode.CBC
    mPadding = PaddingMode.PKCS7
End Sub
