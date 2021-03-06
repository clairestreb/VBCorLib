VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BIntNumberStylesNoneTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' BIntParseNoneTests
'
Option Explicit
Implements ICategorizable
Implements ITestCaseSource

Private Sub ICategorizable_Categorize(ByVal Cat As SimplyVBComp.CategoryCollector)
    Cat.ForFixture "System.Numerics"
End Sub

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "Parse_WithValidValue_ReturnsBigInteger"
            Test.Use "0", NewBytes(0), 0
            Test.Use "1", NewBytes(&H1), 1
            Test.Use "01", NewBytes(&H1), 1
            Test.Use "255", NewBytes(&HFF, 0), 1
            Test.Use "65535", NewBytes(&HFF, &HFF, 0), 1
            
        Case "Parse_WithInvalidValue_ThrowsFormatException"
            Test.Use "-1"
            Test.Use " 1"
            Test.Use "1 "
            Test.Use "(1)"
            Test.Use "+1"
            Test.Use "$1"
            Test.Use "1$"
            Test.Use "1e+10"
            Test.Use "1e10"
            Test.Use "FF"
            Test.Use "1.0"
            Test.Use "1,000"
            Test.Use "1 1"
            Test.Use "1.0"
            Test.Use "1,000"
            
    End Select
End Sub

Public Sub Parse_WithValidValue_ReturnsBigInteger(ByVal s As String, ByRef ExpectedBytes() As Byte, ByVal ExpectedSign As Long)
    Dim Actual As BigInteger
    
    Set Actual = BigInteger.Parse(s, NumberStyles.None)
    
    AssertNumber Actual, ExpectedBytes, ExpectedSign
End Sub

Public Sub Parse_WithInvalidValue_ThrowsFormatException(ByVal s As String)
    On Error Resume Next
    
    BigInteger.Parse s, NumberStyles.None
    
    AssertFormatException Err
End Sub
