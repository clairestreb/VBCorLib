VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ArgumentNullExceptionTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' ArgumentNullExceptionTests
'
Option Explicit
Implements ICategorizable

Private Sub ICategorizable_Categorize(ByVal Cat As SimplyVBComp.CategoryCollector)
    Cat.ForFixture "System"
End Sub

Public Sub Message_WithDefaultConstructor_ReturnsDefaultMessage()
    Dim Ex As New ArgumentNullException
    
    Dim Actual As String
    Actual = Ex.Message
    
    Assert.That Actual, Iz.EqualTo("Value cannot be Nothing.")
End Sub

Public Sub ParamName_WithDefaultConstructor_ReturnsEmpty()
    Dim Ex As New ArgumentNullException
    
    Dim Actual As String
    Actual = Ex.ParamName
    
    Assert.That Actual, Iz.Empty
End Sub

Public Sub Constructor_WithMessage_StoresMessage()
    Const Expected As String = "User Error."
    Dim Ex As ArgumentNullException
    Set Ex = Cor.NewArgumentNullException("", Expected)
    
    Dim Actual As String
    Actual = Ex.Message
    
    Assert.That Actual, Iz.EqualTo(Expected)
End Sub

Public Sub Constructor_WithParamName_AppendsToMessage()
    Dim Ex As ArgumentNullException
    Set Ex = Cor.NewArgumentNullException("Param")
    
    Dim Actual As String
    Actual = Ex.Message
    
    Assert.That Actual, Iz.EqualTo("Value cannot be Nothing." & vbCrLf & "Parameter name: Param")
End Sub

Public Sub Constructor_WithInnerException_StoresInnerException()
    Dim Inner   As New Exception
    Dim Ex      As ArgumentNullException
    Set Ex = Cor.NewArgumentNullException("", , Inner)
    
    Dim Actual As Exception
    Set Actual = Ex.InnerException
    
    Assert.That Actual, Iz.SameAs(Inner)
End Sub

Public Sub GetBaseException_WithNoInnerException_ReturnsSelf()
    Dim Ex As New ArgumentNullException
    
    Dim Actual As Exception
    Set Actual = Ex.GetBaseException
    
    Assert.That Actual, Iz.SameAs(Ex)
End Sub

Public Sub GetBaseException_WithMultipleInnerExceptions_ReturnsDeepestException()
    Dim Inner1 As New Exception
    Dim Inner2 As Exception
    Set Inner2 = Cor.NewException("", InnerException:=Inner1)
    Dim Ex As ArgumentNullException
    Set Ex = Cor.NewArgumentNullException("", InnerException:=Inner2)
    
    Dim Actual As Exception
    Set Actual = Ex.GetBaseException
    
    Assert.That Actual, Iz.SameAs(Inner1)
End Sub

Public Sub Serialization_WhenCalled_SerializesException()
    Const Message As String = "User Error."
    Dim Inner   As New Exception
    Dim Ex      As ArgumentNullException
    Set Ex = Cor.NewArgumentNullException("Param", Message, Inner)
    
    Dim Actual As ArgumentNullException
    Set Actual = Persist(Ex)
    
    Assert.That Actual, Iz.Not.SameAs(Ex)
    Assert.That Actual.Message, Iz.EqualTo(Message & vbCrLf & "Parameter name: Param")
    Assert.That Actual.ParamName, Iz.EqualTo("Param")
    Assert.That Actual.InnerException, Iz.Not.Nothing
End Sub

Public Sub CatchArgumentNull_WithArgumentNullThrown_CatchesException()
    On Error Resume Next
    Dim Ex As New ArgumentNullException
    Throw Ex
    On Error GoTo 0
    
    Dim Actual As Boolean
    Dim ActualEx As ArgumentNullException
    Actual = CatchArgumentNull(ActualEx)
    
    Assert.That Actual, Iz.True
    Assert.That ActualEx, Iz.SameAs(Ex)
    Assert.Pass
End Sub

Public Sub CatchArgumentNull_WithNonArgumentNullThrown_DoesNotCatch()
    On Error Resume Next
    Throw New SystemException
    On Error GoTo 0
    
    Dim Actual As Boolean
    Dim ActualEx As ArgumentNullException
    Actual = CatchArgumentNull(ActualEx)
    
    Assert.That Actual, Iz.False
    Assert.That ActualEx, Iz.Nothing
    Assert.Pass
End Sub
