VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ASCIIEncodingTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' TestASCIIEncoding
'
Option Explicit
Implements ITestCaseSource

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "GetBytes_WithChars_ReturnsExpected"
            Test.Use vbNullChar, NewBytes(0)
            Test.Use vbTab, NewBytes(9)
            Test.Use Chr$(127), NewBytes(127)
            Test.Use Chr$(128), NewBytes(63)
            Test.Use ChrW$(&HFFFF), NewBytes(63)
            Test.Use "ABC", NewBytes(65, 66, 67)
            Test.Use NewIntegers(96, 97, 98), NewBytes(96, 97, 98)
            Test.Use "", NewBytes()
            Test.Use NewIntegers(), NewBytes()
            
        Case "GetBytes_WithIndexAndCount_ReturnsExpectedSubset"
            Test.Use "abcd", NewBytes(98, 99)
            Test.Use NewIntegers(97, 98, 99, 100), NewBytes(98, 99)
            
        Case "GetByteCount_WithCharacters_ReturnsExpected"
            Test.Use "abc", 3
            Test.Use "", 0
            Test.Use NewIntegers(97, 98, 99, 100), 4
            Test.Use NewIntegers(), 0
            
        Case "GetCharCount_WithBytes_ReturnsExpected"
            Test.Use NewBytes(1), 1
            Test.Use NewBytes(1, 2, 3, 4, 5), 5
            Test.Use NewBytes(), 0
        
        Case "GetString_WithBytes_ReturnsExpected"
            Test.Use NewBytes(48, 49, 50), "012"
            Test.Use NewBytes(), ""
            Test.Use NewBytes(255, 65, 128, 0), "?A?" & vbNullChar
            
        Case "GetChars_WithBytes_ReturnsExpected"
            Test.Use NewBytes(48, 49, 50), NewIntegers(48, 49, 50)
            Test.Use NewBytes(), NewIntegers()
            Test.Use NewBytes(255, 65, 128, 0), NewIntegers(63, 65, 63, 0)
        
    End Select
End Sub

Public Sub GetBytes_WithChars_ReturnsExpected(ByRef Chars As Variant, ByRef Expected() As Byte)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual() As Byte
    Actual = Encoding.GetBytes(Chars)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetBytes_WithIndexAndCount_ReturnsExpectedSubset(ByRef Chars As Variant, ByRef Expected() As Byte)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual() As Byte
    Actual = Encoding.GetBytes(Chars, 1, 2)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetByteCount_WithCharacters_ReturnsExpected(ByRef Chars As Variant, ByVal Expected As Long)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual As Long
    Actual = Encoding.GetByteCount(Chars)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetByteCount_WithIndexAndCount_ReturnsExpected()
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual As Long
    Actual = Encoding.GetByteCount("abc", 1, 2)
    
    Assert.That Actual, Iz.EqualTo(2)
End Sub

Public Sub GetBytesEx_WithCharsThatFitIntoOutput_EncodesAllChars()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    ReDim Bytes(1 To 10)
    
    Dim ActualCount As Long
    ActualCount = Encoding.GetBytesEx("12345", 0, 5, Bytes, 1)
    
    Assert.That ActualCount, Iz.EqualTo(5)
    Assert.That Bytes, Iz.EqualTo(NewBytes(49, 50, 51, 52, 53, 0, 0, 0, 0, 0)).AsCollection
End Sub

Public Sub GetBytesEx_WithSubsetSpecified_EncodesSubset()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    ReDim Bytes(1 To 10)
    
    Dim ActualCount As Long
    ActualCount = Encoding.GetBytesEx("12345678", 1, 4, Bytes, 1)
    
    Assert.That ActualCount, Iz.EqualTo(4)
    Assert.That Bytes, Iz.EqualTo(NewBytes(50, 51, 52, 53, 0, 0, 0, 0, 0, 0)).AsCollection
End Sub

Public Sub GetBytesEx_WithEmptyCharacters_DoesNotFill()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    ReDim Bytes(1 To 10)
    
    Dim ActualCount As Long
    ActualCount = Encoding.GetBytesEx("", 0, 0, Bytes, 1)
    
    Assert.That ActualCount, Iz.EqualTo(0)
    Assert.That Bytes, Iz.All.EqualTo(0)
End Sub

Public Sub GetCharCount_WithBytes_ReturnsExpected(ByRef Bytes() As Byte, ByVal Expected As Long)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual As Long
    Actual = Encoding.GetCharCount(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetString_WithBytes_ReturnsExpected(ByRef Bytes() As Byte, ByVal Expected As String)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual As String
    Actual = Encoding.GetString(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetString_WithSubsetSpecified_ReturnsSubset()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    Bytes = NewBytes(255, 255, 48, 49, 50, 255, 255)
    
    Dim Actual As String
    Actual = Encoding.GetString(Bytes, 2, 3)
    
    Assert.That Actual, Iz.EqualTo("012")
End Sub

Public Sub GetChars_WithBytes_ReturnsExpected(ByRef Bytes() As Byte, ByRef Expected() As Integer)
    Dim Encoding As New ASCIIEncoding
    
    Dim Actual() As Integer
    Actual = Encoding.GetChars(Bytes)
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub GetChars_WithSubsetSpecified_ReturnsSubset()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    Bytes = NewBytes(255, 255, 48, 49, 50, 255, 255)
    
    Dim Actual() As Integer
    Actual = Encoding.GetChars(Bytes, 2, 3)
    
    Assert.That Actual, Iz.EqualTo(NewIntegers(48, 49, 50))
End Sub

Public Sub GetCharsEx_WithBytes_ReturnsExpected()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    Bytes = NewBytes(48, 49, 50)
    
    
    Dim ActualChars(0 To 5) As Integer
    Dim ActualCount As Long
    ActualCount = Encoding.GetCharsEx(Bytes, 0, 3, ActualChars, 0)
    
    Assert.That ActualCount, Iz.EqualTo(3)
    Assert.That ActualChars, Iz.EqualTo(NewIntegers(48, 49, 50, 0, 0, 0))
End Sub

Public Sub GetCharsEx_WithSubsetSpecified_ReturnsSubset()
    Dim Encoding As New ASCIIEncoding
    Dim Bytes() As Byte
    Bytes = NewBytes(48, 49, 50, 51, 52)
    
    
    Dim ActualChars(0 To 5) As Integer
    Dim ActualCount As Long
    ActualCount = Encoding.GetCharsEx(Bytes, 2, 2, ActualChars, 1)
    
    Assert.That ActualCount, Iz.EqualTo(2)
    Assert.That ActualChars, Iz.EqualTo(NewIntegers(0, 50, 51, 0, 0, 0))
End Sub










