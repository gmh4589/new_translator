#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ComboConstants.au3>
#include <Constants.au3>
#include <File.au3>
#include <Array.au3>
#include <GDIPlus.au3>
#include <MsgboxConstants.au3>
#Include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <Date.au3>

Localize()

$hGui = GUICreate($tProgName, 600, 300, -1, -1, $WS_OVERLAPPEDWINDOW, $WS_EX_ACCEPTFILES)

Global $iDrive, $iDir, $iName, $iExp, $a, $b, $c = 0, $iCountLines, $iResultFile, $iStartReading, $L, $Hour, $Mins, $Secs, $iStrArray, $iDictionary
Global $iDictLang = IniRead('data\translator.ini', 'Local', 'Dict', 'russian')
Global $iDefAPI = IniRead('data\translator.ini', 'Local', 'DefaultTl', 'google')

	$iOpenQuick = GUICtrlCreateButton("1", 0, 0, 40, 40, $BS_ICON) ;Кнопка "открыть файл"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\open.ico")
	GUICtrlSetTip(-1, $tOpenFile)
	GUICtrlSetResizing ($iOpenQuick, $GUI_DOCKALL)
		
	$idButtonBack = GUICtrlCreateButton("1", 40, 0, 40, 40, $BS_ICON) ;Кнопка "назад"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\left_arrow.ico")
	GUICtrlSetTip(-1, $tBack)
	GUICtrlSetResizing ($idButtonBack, $GUI_DOCKALL)
		
	$idButton1a = GUICtrlCreateButton("1", 80, 0, 40, 40, $BS_ICON) ;Кнопка "дальше\вперед"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\right_arrow.ico")
	GUICtrlSetTip(-1, $tNext)
	GUICtrlSetResizing ($idButton1a, $GUI_DOCKALL)
		
	$idButton2a = GUICtrlCreateButton("1", 120, 0, 40, 40, $BS_ICON) ;Кнопка "перейти к..."
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\goto.ico")
	GUICtrlSetTip(-1, $tGoto)
	GUICtrlSetResizing ($idButton2a, $GUI_DOCKALL)
		
	$idButtonReturnOrig = GUICtrlCreateButton("1", 160, 0, 40, 40, $BS_ICON) ;Кнопка "Вернуть оригинальный текст"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\refresh.ico")
	GUICtrlSetTip(-1, $tReturnOrig)
	GUICtrlSetResizing ($idButtonReturnOrig, $GUI_DOCKALL)
		
	$idButtonFind = GUICtrlCreateButton("1", 200, 0, 40, 40, $BS_ICON) ;Кнопка "поиска и замена"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\find.ico")
	GUICtrlSetTip(-1, $tFindNChange)
	GUICtrlSetResizing ($idButtonFind, $GUI_DOCKALL)
		
	$idButtonBackup = GUICtrlCreateButton("1", 240, 0, 40, 40, $BS_ICON) ;Кнопка "Создать резервную копию"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\copy.ico")
	GUICtrlSetTip(-1, $tCreateBackup)
	GUICtrlSetResizing ($idButtonBackup, $GUI_DOCKALL)
		
	$idButtonYT = GUICtrlCreateButton("1", 280, 0, 40, 40, $BS_ICON) ;Кнопка "Создать резервную копию"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\translate.ico")
	GUICtrlSetTip(-1, $tOnlineT)
	GUICtrlSetResizing ($idButtonYT, $GUI_DOCKALL)
		
	$idButtonExit = GUICtrlCreateButton("15", 560, 0, 40, 40, $BS_ICON) ;Кнопка "выйти"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\off.ico")
	GUICtrlSetTip(-1, $tExit)
	GUICtrlSetResizing ($idButtonExit, $GUI_DOCKRIGHT + $GUI_DOCKSIZE)
		
	$idButtonDic = GUICtrlCreateButton("1", 520, 0, 40, 40, $BS_ICON) ;Кнопка "Создать словарь"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\book.ico")
	GUICtrlSetTip(-1, $tCreateDict)
	GUICtrlSetResizing ($idButtonDic, $GUI_DOCKRIGHT + $GUI_DOCKSIZE)
	
	$idButtonSetting = GUICtrlCreateButton("1", 480, 0, 40, 40, $BS_ICON) ;Кнопка "Настройки"
	GUICtrlSetImage(-1, @ScriptDir & "\data\icon\setting.ico")
	GUICtrlSetTip(-1, $tSetting)
	GUICtrlSetResizing ($idButtonDic, $GUI_DOCKRIGHT + $GUI_DOCKSIZE)
		
	$iTranslateSelect = GUICtrlCreateCombo("", 325, 5, 100, 20, $CBS_DROPDOWNLIST + $WS_VSCROLL)
	GUICtrlSetData(-1, "Yandex|Google|Bing", $iDefAPI)
	GUICtrlSetTip(-1, $tSelectTr)
	
$idButton1 = GUICtrlCreateButton($tNext, 300, 250, 120, 40, $BS_ICON)  ;Кнопка "дальше" внизу интерфейса
$idButton2 = GUICtrlCreateButton($tGoto, 420, 250, 120, 40, $BS_ICON) ;Кнопка "перейти к..." внизу интерфейса

GUICtrlCreateLabel ($tOriginal, 5, 45, 100, 20) ;Место под оригинальный текст, лейбл, править нельзя
Global $iOriginal = GUICtrlCreateLabel('', 5, 60, 290, 180, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_NOHIDESEL + $ES_WANTRETURN)
GUICtrlSendMsg($iOriginal, $EM_LIMITTEXT, -1, 0)
GUICtrlSetFont ($iOriginal, 12)

GUICtrlCreateLabel ($tTranslate, 300, 45, 100, 20) ;Место под переведенный текст, эдит-бокс, править можно
Global $iTranslate = GUICtrlCreateEdit('', 300, 60, 295, 180, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_NOHIDESEL + $ES_WANTRETURN)
GUICtrlSendMsg($iTranslate, $EM_LIMITTEXT, -1, 0)
GUICtrlSetFont ($iTranslate, 12)

Global $iProgressMeter = GUICtrlCreateLabel ('0/0 ' & $tComplete, 5, 250, 120, 20) ;Счетчик готовых строк с текстом
Global $iProgressBar = GUICtrlCreateProgress (0, 295, 600, 5) ;Полоска прогресса перевода
Global $iLeterMeter = GUICtrlCreateLabel ('0 ' & $tSymbols, 5, 270, 100, 20) ;Счетчик длины символов в текущей строке
Global $iStringMeter = GUICtrlCreateLabel ($tString & ' 0/0', 155, 250, 120, 20) ;Счетчик всех строк
Global $iProgressData = GUICtrlCreateLabel ('0 %', 555, 270, 120, 20) ;Счетчик прогресса в процентах

	GUISetState(@SW_SHOW)
	
If FileExists (@ScriptDir & "\data\translator.ini") = 1 Then
	$iFileName = IniRead('data\translator.ini', 'LastFile', 'Name', '')
	If $iFileName <> '' and FileExists($iFileName) Then
			OpenOrResume()
		Else
			Open1()
	EndIf
Else
	Open1()
EndIf

;Цикл опроса интерфейса

While 1
	Switch GUIGetMsg($hGui)
	Case $GUI_EVENT_CLOSE, $idButtonExit
		Switch MsgBox (3, $tMsg, $tMsg1 & @CRLF & $tYesSave & @CRLF & $tNoSave & @CRLF & $tCanselSave)
			Case 6
				NextString()
				IniWrite ('data\translator.ini', 'LastFile', 'Name', $iFileName)
				ExitLoop
			Case 7
				IniWrite ('data\translator.ini', 'LastFile', 'Name', $iFileName)
				ExitLoop
			Case 2
				Sleep(1)
		EndSwitch
	Case $iOpenQuick
		Global $iFileName = FileOpenDialog ($tSelFile, @ScriptDir, 'XML ' & $tFiles & ' (*.xml)')
			If @error = 1 then ContinueLoop
			OpenOrResume()
	Case $idButton1, $idButton1a
			NextString()
			Sleep (1000)
	Case $idButton2, $idButton2a
			LetsGo()
	Case $idButtonBack
			ComeBack()
			Sleep (1000)
	Case $idButtonFind
			$iFind = InputBox ($tFind, $tEnterText, GUICtrlRead ($iOriginal), '', 250, 130)
				If @error = 0 Then
					$iReplace = InputBox ($tCange, $tEnterText, GUICtrlRead ($iOriginal), '', 250, 130)
						If @error = 0 Then
							FindAndReplace($iFind, $iReplace)
						EndIf
				EndIf
	Case $idButtonBackup
			BackUper(@ScriptDir & '\' & $iName & '_translate.xml')
	Case $idButtonReturnOrig
			GUICtrlSetData($iTranslate, GUICtrlRead($iOriginal))
	Case $idButtonDic
			DictCreater()
	Case $idButtonYT
		$Text2TL =  GUICtrlRead($iOriginal)
			If StringInStr($Text2TL, '#') > 0 then $Text2TL = StringReplace ($Text2TL, '#', ' ')
			If StringInStr($Text2TL, '•••') > 0 then $Text2TL = StringReplace ($Text2TL, ' ••• ', ' ')
			If GUICtrlRead ($iTranslateSelect) = "Yandex" Then
				ShellExecute ("https://translate.yandex.ru/?utm_source=main_stripe_big&lang=en-ru&text=" & $Text2TL)
			ElseIf GUICtrlRead ($iTranslateSelect) = "Google" Then
				ShellExecute ("https://translate.google.ru/?hl=ru&tab=rT&sl=en&tl=ru&text=" & $Text2TL)
			ElseIf GUICtrlRead ($iTranslateSelect) = "Bing" Then
				ShellExecute ("https://www.bing.com/translator/?text=" & $Text2TL)
			EndIf
	Case $idButtonSetting
		Setting()
	EndSwitch
WEnd

Func Open1()
	Global $iFileName = FileOpenDialog ($tSelFile, @ScriptDir, 'XML ' & $tFiles & ' (*.xml)')
		If @error = 0 then
			OpenOrResume()
		EndIf
EndFunc

Func OpenOrResume() ;Открывает новый файл или продолжает старый
	$iCountLines = _FileCountLines($iFileName)
	_PathSplit($iFileName, $iDrive, $iDir, $iName, $iExp)
	GUICtrlCreateLabel ($tNowOpen & $iName & $iExp, 155, 270, 130, 20)
	
	If FileExists (@ScriptDir & '\' & $iName & '_translate.xml') Then
		If _FileCountLines(@ScriptDir & '\' & $iName & '_translate.xml') = $iCountLines Then
			$Ans = MsgBox(4, $tMsg, $tMsg2 & @CRLF & $tExit & '?')
				If $Ans = 6 Then Exit
		Else
			BackUper(@ScriptDir & '\' & $iName & '_translate.xml')
			_FileDeleteEmptyLines(@ScriptDir & '\' & $iName & '_translate.xml')
			$iResultFile = FileOpen (@ScriptDir & '\' & $iName & '_translate.xml', 1)
			$a = Round((_FileCountLines(@ScriptDir & '\' & $iName & '_translate.xml')-6)/2)
			$b = Round((_FileCountLines($iFileName)-4)/2)
			$c = _FileCountLines(@ScriptDir & '\' & $iName & '_translate.xml') + 1
			$iStartReading  = FileOpen($iFileName)
			FileWriteLine ($iResultFile, @CRLF)
			GUICtrlSetData ($iProgressMeter, $a & '/' & $b - 3 & ' ' & $tComplete)
			
				GetText()
		EndIf
	Else
		FileCopy ($iFileName, $iDrive & $iDir & '\' & $iName & '_original.xml')
		FileOpen ($iFileName, 0)
		$iDataMain = FileRead ($iFileName)
		$iNewText = StringRegExpReplace ($iDataMain, '</Entry>\R      <Entry data="AQ==" />\R      <Entry>', ' ••• ')
		FileClose ($iFileName)
		FileOpen ($iFileName, 2)
		FileWrite ($iFileName, $iNewText)
		FileClose ($iFileName)
		FileOpen ($iFileName, 0)
		$iCountLines = _FileCountLines($iFileName)
		$a = 1
		$b = Round((_FileCountLines($iFileName)-4)/2)
		$c = 7
		GUICtrlSetData ($iProgressMeter, $a & ' из ' & $b - 3 & ' ' & $tComplete)
		$iStartReading  = FileOpen($iFileName)
		$iResultFile = FileOpen (@ScriptDir & '\' & $iName & '_translate.xml', 2)
		
			For $i = 1 to 6
				$iString = FileReadLine ($iStartReading, $i)
				FileWriteLine ($iResultFile, $iString)
			Next
		
				GetText()
	EndIf
EndFunc

Func NextString() ;Переходит на следующую строку 
		$iString = Orpho(GUICtrlRead ($iTranslate))

		$c += 1
		
		FileWriteLine ($iResultFile, '      <Entry>' & $iString & '</Entry>')
		Sleep (100)
		$iStartReading  = FileOpen($iFileName)
		$iString = FileReadLine ($iStartReading, $c)
		FileWriteLine ($iResultFile, $iString)
		
			If $c >= $b * 2 Then
				MsgBox(0, $tMsg, $tMsg3)
				$iFinish = FileRead ($iStartReading)
				FileWrite ($iResultFile, $iFinish)
				FileSetPos ($iResultFile, 0, 0)
				$iDataMain = FileRead ($iResultFile)
				$iNewText = StringRegExpReplace ($iDataMain, '•••', '</Entry>' &  @CRLF & '      <Entry data="AQ==" />' &  @CRLF & '      <Entry>')
				FileClose ($iResultFile)
				$iResultFile = FileOpen (@ScriptDir & '\' & $iName & '_translate.xml', 2)
				FileWrite ($iResultFile, $iNewText)
				FileClose ($iResultFile)
				;FileDelete (@ScriptDir & "\data\translator.ini")
				Exit
			EndIf
			
		$c += 1
		$a += 1

			GetText()
EndFunc

Func LetsGo() ;Пропускает указанное количество строк
	$iLetsGo = InputBox ($tGo2Str, $tStrN, $c + 1, '', 250, 130)
	
	If @error = 1 then Return
	If Mod($iLetsGo, 2) = 0 Then $iLetsGo=$iLetsGo+1
	
		If $iLetsGo > $c Then
			$iStartReading  = FileOpen($iFileName)
			$c += 1
			$iString = GUICtrlRead ($iTranslate)
			FileWriteLine ($iResultFile, '      <Entry>' & $iString & '</Entry>')
			ProgressOn('', $tWait, "")
			$o = 0
			
				For $i = $c to $iLetsGo - 1
					$iString = FileReadLine ($iStartReading, $i)
					FileWriteLine ($iResultFile, $iString)
					ProgressSet((100/($iLetsGo - $i)) * $o)
					$o += 1
				Next
				
			ProgressSet(100, $tDone)
			ProgressOff()
			$a = Round((($iLetsGo - $c)/2) + $a)
			$c = $iLetsGo
			
				GetText()
		Else
			MsgBox (0, $tMsg, $tMsg4 & @CRLF & $tMsg5)
		EndIf
		
EndFunc

Func ComeBack() ;Возвращается на строку назад
	FileClose ($iResultFile)
	
	For $ooo = 1 to 2
		_FileWriteToLine ( @ScriptDir & '\' & $iName & '_translate.xml', _FileCountLines(@ScriptDir & '\' & $iName & '_translate.xml'), '', 1)
	Next
	
	$c = $c - 2
	
	If Mod($c, 2) = 0 Then 
		$c -= 1
		_FileWriteToLine ( @ScriptDir & '\' & $iName & '_translate.xml', _FileCountLines(@ScriptDir & '\' & $iName & '_translate.xml'), '', 1)
	EndIf
	
	$iStartReading  = FileOpen($iFileName)	
	$iResultFile = FileOpen (@ScriptDir & '\' & $iName & '_translate.xml', 1)
	GetText()
EndFunc

Func FindAndReplace($iFind, $iReplace) ;Ищет и заменяет текст во всем файле

	FileClose ($iFileName)
	FileOpen ($iFileName, 0)
	
	Local $iArray[3] = [' ', '>', '*'], $iArray1[8] = [' ', '<', ',', '.', '!', '?', ':', '*'], $iCR = 0
	
	ProgressOn('', $tWait, "")
	$set = 0
	
	For $t = 0 to 2
	
		For $u = 0 to 7
			$iDataMain = FileRead ($iFileName)
			$iNewText = StringReplace ($iDataMain, $iArray[$t] & $iFind & $iArray1[$u], $iArray[$t] & $iReplace & $iArray1[$u])
			$iCR = @extended + $iCR
			FileClose ($iFileName)
			FileOpen ($iFileName, 2)
			FileWrite ($iFileName, $iNewText)
			FileClose ($iFileName)
			FileOpen ($iFileName, 0)
			ProgressSet(2 * ($u + 1) + $set)
		Next
		
	$set = 50
	Next
	
	ProgressSet(100, $tDone)
	ProgressOff()
	
	MsgBox (0, $tMsg, $tCompleted & $iCR & $tReplace)
	
	GUICtrlSetData($iTranslate, $iReplace)

EndFunc

Func GetText() ;Читает строку из файла, устанавливает данные для счетчиков
	$iSatrtText = StringTrimRight(StringTrimLeft(FileReadLine ($iStartReading, $c), 13), 8)
	$x = StringLen ($iSatrtText)
	GUICtrlSetData ($iProgressMeter, $a & '/' & $b - 3 & ' ' & $tComplete)
	GUICtrlSetData ($iLeterMeter, $x & ' ' & $tSymbols)
	GUICtrlSetData ($iStringMeter, $tString & ' ' & $c & '/' & $iCountLines)
	GUICtrlSetData ($iProgressBar, ((100/$iCountLines) * $c))
	GUICtrlSetData ($iProgressData, StringLeft(((100/$iCountLines) * $c), 5) & " %")
	GUICtrlSetData($iOriginal, $iSatrtText)
	GUICtrlSetData($iTranslate, $iSatrtText)
	GUICtrlSetLimit ($iTranslate, $x)
	FileClose ($iStartReading)
EndFunc

Func Orpho ($iOrpho) ;Проверяет орфографию слов в переводе
	$iStringArray = StringSplit ($iOrpho, ' .,!?;:-"()•*\[]()_' & "'")
	
	For $i = 1 to UBound($iStringArray)-1
	;Определяем имя тома словаря
		
		If StringInStr($iStringArray[$i], 'n') = 1 Then $iStringArray[$i] = StringReplace ($iStringArray[$i], 'n', '')
		If StringLen ($iStringArray[$i]) = 0 or StringInStr ($iStringArray[$i], '#') > 0 or StringInStr ($iStringArray[$i], '_') > 0 or StringIsDigit ($iStringArray[$i]) Then
			ContinueLoop
		ElseIf StringLen ($iStringArray[$i]) < 4 Then
			$Dist = ("short.txt")
		ElseIf StringInStr ( $iStringArray[$i], "aux") = 1 Then
			$Dist = ("_aux.txt")
		Else
			$Dist = (StringLeft ($iStringArray[$i], 3) & ".txt")
		EndIf
		
	;Если том не найден, значит и слова нет
	
		If Not FileExists (@ScriptDir & '\data\dictionary\' & $iDictLang & '\' & $Dist) Then
			$iOrpho = StringRegExpReplace ($iOrpho, $iStringArray[$i], FindWords($iStringArray[$i]))
			ContinueLoop
		EndIf
		
	;Если найден, ищем в нем слово
	$iDictionary = StringSplit (FileRead (@ScriptDir & '\data\dictionary\' & $iDictLang & '\' & $Dist), '	')
	$L = 0 ;Флажок ошибок
	
		For $j = 1 to UBound($iDictionary)-1
		
			If StringCompare ($iStringArray[$i], $iDictionary[$j], 0) = 0 then
				$L += 1
				;MsgBox (0, "Сообщение 1", "Слово '" & $iStringArray[$i] & "' найдено!" & @CR & $j)
	;Если слово в словаре найдено, переходим к следующему
				ExitLoop
			EndIf
			
		Next
		
	;Если не найдено, предлагаем добавить в словарь или перейти к следующему слову
	
		If $L < 1 Then ;Если есть ошибка, меняет слово с ошибкой на исправленное
			$iOrpho = StringRegExpReplace ($iOrpho, $iStringArray[$i], FindWords($iStringArray[$i]))
		EndIf
		
	Next	
	;Конечно, можно сделать словарь одним файлом и через _FileReadToArray и поиск по массиву, но так проверка орфографии каждого слова длиться очень долго...
	Return ($iOrpho)
EndFunc

Func FindWords($iWord) ;Предлагает добавить слово в словарь, исправить ошибку или проигнорировать, если слово в словаре нет

	Switch MsgBox (3, $tMsg, $tWord & $iWord & $tNotFind & @CRLF & $tAdd2Dict & @CRLF & $tYesAdd & @CRLF & $tNoAdd & @CRLF & $tCancelFix)
		Case 6
			If StringLen ($iWord) < 4 Then
				$iNewVol = FileOpen (@ScriptDir & '\data\dictionary\' & $iDictLang & '\' & 'short.txt', 9)
			Else
				$iNewVol = FileOpen (@ScriptDir & '\data\dictionary\' & $iDictLang & '\' & StringLeft (StringLower($iWord), 3) & ".txt", 9)
			EndIf
			FileWrite ($iNewVol, StringLower($iWord) & @TAB)
			FileClose ($iNewVol)
		Case 7
			SetError (0)
		Case 2
			$iWord = InputBox ($tFix, $tFix2 & $iWord & '"', $iWord)
	EndSwitch
	
	Return($iWord)
EndFunc

Func _FileDeleteEmptyLines($sFile) ;Удаляет пустые строки в файле
    $sFileContent = StringRegExpReplace(FileRead($sFile), "(\r?\n){1,}", "\1")
    $hFOpen = FileOpen($sFile, 2)
    FileWrite($hFOpen, StringStripWS($sFileContent, 3))
    FileClose($hFOpen)
EndFunc

Func BackUper($File20) ;Создает резервные копии переводов
	Local $iDr20, $iDi20, $iN20, $iE20
	_PathSplit($File20, $iDr20, $iDi20, $iN20, $iE20)
	$i = 0	
		Do
			$i += 1
		Until Not FileExists (@scriptdir & "\data\backup\" & $iN20 & "_bak_" & $i & ".xml")

	FileCopy ($File20, @scriptdir & "\data\backup\" & $iN20 & "_bak_" & $i & ".xml", 8)
EndFunc

Func DictCreater()

$begin = TimerInit()

$iDicPath = FileOpenDialog ('', @ScriptDir, $tTextFiles & " (*.txt)")
If @error = 1 then Return
_PathSplit ($iDicPath, $iDrive, $iDir, $iName, $iExp)
$iName = InputBox ($tDict, $tEnterName, $iName)
_FileReadToArray($iDicPath, $iStrArray)


If @error = 0 Then
	$path = @ScriptDir & "\data\dictionary\" & $iName & "\"

	$a = $iStrArray[0]

	ProgressOn('', $tWait, "", (@DesktopWidth/2)-150, (@DesktopHeight/2)-60, 18)

		For $i = 1 to $a
			$string = $iStrArray[$i]
			
				If StringLen ($string) < 4 Then
					$Dist = ("short.txt")
				ElseIf StringInStr ( $string, "-") = 1 Then
					$Dist = ("short.txt")
				ElseIf StringInStr ( $string, ".") = 2 Then
					$Dist = ("short.txt")
				ElseIf StringInStr ( $string, "aux") = 1 Then
					$Dist = ("_aux.txt")
				Else
					$Dist = (StringLeft ($string, 3) & ".txt")
				EndIf
				If Not FileExists ($path & $Dist) Then
					FileOpen ($path & $Dist, 9)
				EndIf
				
			FileWriteLine ($path & $Dist, $string)
			$Percent = 100/$a * $i
			$dif = TimerDiff($begin)
			$elaps = (($dif/$i) * $a) - $dif
			_TicksToTime(Int($dif), $Hour, $Mins, $Secs)
			$time = StringFormat("%02i:%02i:%02i", $Hour, $Mins, $Secs)
			_TicksToTime(Int($elaps), $Hour, $Mins, $Secs)
			$elaps = StringFormat("%02i:%02i:%02i", $Hour, $Mins, $Secs)
			ProgressSet ($Percent, $tAdd & $i & $tWordFrom & $a & @CRLF & StringLeft ($Percent, 4) & ' %' & @CRLF & $tPass & $time & @TAB & $tElaps & $elaps)
		Next
		
	$dif = TimerDiff($begin)
	_TicksToTime(Int($dif), $Hour, $Mins, $Secs)
	$dif = StringFormat("%02i:%02i:%02i", $Hour, $Mins, $Secs)
	ProgressSet(100, $tDone & @CRLF & $tElaps  & $dif)
	MsgBox (0, $tMsg, $tDone)
	ProgressOff()
EndIf

EndFunc

Func Setting()

Local $NewLNG = _FileListToArray('data\local', '*.ini'), $NewDCT = _FileListToArray('data\dictionary', '*', 2), $iLangList = '', $iDictList = ''

For $z = 1 to UBound($NewLNG)-1
	$Langz = StringReplace($NewLNG[$z], '.ini', '')
	$iLangList = $iLangList & $Langz & '|'
Next

For $z = 1 to UBound($NewDCT)-1
	$Langz = StringReplace($NewDCT[$z], '.ini', '')
	$iDictList = $iDictList & $Langz & '|'
Next

Global $AGUI = GUICreate($tSetting, 140, 180, -1, -1)
	GUISetState(@SW_SHOW, $AGUI)
	GUISetIcon (@ScriptDir & "\Data\icon\setting.ico")
	; $iLangList = IniRead('data\translator.ini', 'Local', 'LangList', 'english|russian')
	; $iDictList = IniRead('data\translator.ini', 'Local', 'DictList', 'english|russian')

GUICtrlCreateLabel($tLanguage, 10, 5, 100, 14)
Global $iLang = GUICtrlCreateCombo("", 10, 20, 120, 100)
GUICtrlSetData(-1, $iLangList, $tLang)

GUICtrlCreateLabel($tDict, 10, 45, 100, 14)
Global $iDicSet = GUICtrlCreateCombo("", 10, 60, 120, 100)
GUICtrlSetData(-1, $iDictList, $iDictLang)

GUICtrlCreateLabel($tDefTransl, 10, 85, 100, 14)
Global $iTlSet = GUICtrlCreateCombo("", 10, 100, 120, 100)
GUICtrlSetData(-1, "Google|Yandex|Bing", IniRead('data\translator.ini', 'Local', 'DefaultTl', $iDefAPI))

Global $iBtnSaveSetup = GUICtrlCreateButton($tSaveSet, 20, 135, 100, 30)

SettingWhile()

EndFunc

Func SettingWhile()
		While 1
			Switch GUIGetMsg($AGUI)
				Case $GUI_EVENT_CLOSE
					GUISetState(@SW_HIDE, $AGUI)
						ExitLoop
				Case $iBtnSaveSetup
					IniWrite('data\translator.ini', 'Local', 'Lang', GUICtrlRead($iLang))
					IniWrite('data\translator.ini', 'Local', 'Dict', GUICtrlRead($iDicSet))
					IniWrite('data\translator.ini', 'Local', 'DefaultTl', GUICtrlRead($iTlSet))
					_ScriptRestart(500)
			EndSwitch
		WEnd
EndFunc

Func Localize()
	Global $tLang = IniRead('data\translator.ini', 'Local', 'Lang', 'english')
	Global $tProgName = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tProgName', 'Переводчик')
	Global $tOpenFile = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tOpenFile', 'Открыть файл')
	Global $tBack = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tBack', 'Назад')
	Global $tNext = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tNext', 'Дальше')
	Global $tGoto = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tGoto', 'Перейти к...')
	Global $tReturnOrig = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tReturnOrig', 'Вернуть оригинальный текст')
	Global $tFindNChange = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tFindNChange', 'Поиск и замена')
	Global $tCreateBackup = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCreateBackup', 'Создать резервную копию')
	Global $tOnlineT = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tOnlineT', 'Перевести онлайн')
	Global $tExit = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tExit', 'Выйти')
	Global $tCreateDict = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCreateDict', 'Создать словарь')
	Global $tSelectTr = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tSelectTr', 'Выбрать онлайн-переводчик')
	Global $tOriginal = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tOriginal', 'Оригинал')
	Global $tTranslate = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tTranslate', 'Перевод')
	Global $tComplete = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tComplete', 'готово')
	Global $tSymbols = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tSymbols', 'символов')
	Global $tString = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tString', 'Строка')
	Global $tMsg = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg', 'Сообщение')
	Global $tMsg1 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg1', 'Сохранить текущую строку?')
	Global $tYesSave = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tYesSave', 'Да - сохранить и выйти')
	Global $tNoSave = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tNoSave', 'Нет - Выйти без сохранения')
	Global $tCanselSave = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCanselSave', 'Отмена - продолжить переводить')
	Global $tSelFile = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tSelFile', 'Выберите файл')
	Global $tFiles = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tFiles', 'Файлы')
	Global $tFind = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tFind', 'Найти')
	Global $tCange = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCange', 'Заменить')
	Global $tEnterText = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tEnterText', 'Введите текст: ')
	Global $tNowOpen = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tNowOpen', 'Открыт файл: ')
	Global $tMsg2 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg2', 'Этот файл уже переведен!')
	Global $tMsg3 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg3', 'Достигнут конец файла!')
	Global $tGo2Str = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tGo2Str', 'Перейти к строке')
	Global $tStrN = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tStrN', 'Номер строки: ')
	Global $tWait = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tWait', 'Подождите...')
	Global $tDone = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tDone', 'Готово!')
	Global $tMsg4 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg4', 'Номер строки должен быть нечетным')
	Global $tMsg5 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tMsg5', 'и быть больше текущей строки!')
	Global $tCompleted = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCompleted', 'Выполнено ')
	Global $tReplace = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tReplace', ' замен')
	Global $tWord = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tWord', 'Слово ')
	Global $tNotFind = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tNotFind', ' не найдено!')
	Global $tAdd2Dict = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tAdd2Dict', 'Добавить в словарь?')
	Global $tYesAdd = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tYesAdd', 'Да - добавить')
	Global $tNoAdd = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tNoAdd', 'Нет - пропустить, перейти к следующему слову')
	Global $tCancelFix = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tCancelFix', 'Отмена - исправить')
	Global $tFix = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tFix', 'Исправьте слово')
	Global $tFix2 = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tFix2', 'Исправьте ошибку в слове "')
	Global $tTextFiles = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tTextFiles', 'Текстовые файлы')
	Global $tDict = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tDict', 'Словарь')
	Global $tEnterName = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tEnterName', 'Введите название словаря:')
	Global $tAdd = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tAdd', 'Добавлено ')
	Global $tWordFrom = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tWordFrom', ' слов из ')
	Global $tPass = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tPass', 'Прошло: ')
	Global $tElaps = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tElaps', 'Осталось: ')
	Global $tSetting = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tSetting', 'Настройки')
	Global $tDefTransl = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tDefTransl', 'Переводчик по умолчанию')
	Global $tLanguage = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tLanguage', 'Язык\Language')
	Global $tSaveSet = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tSaveSet', 'Применить')
	Global $tAddLocal = IniRead('data\local\' & $tLang & '.ini', 'Local', 'tAddLocal', 'Добавить язык')
	
EndFunc

Func _ScriptRestart($iTime)
	Sleep ($iTime)
	$hFile = FileOpen(@TempDir & "\temp.bat", 10)
	FileWriteLine ($hFile, @ScriptFullPath)
	FileClose ($hFile)
		ShellExecute (@TempDir & "\temp.bat", "", @ScriptDir, "open", @SW_HIDE)
	Exit
EndFunc