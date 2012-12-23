@echo off
REM ============================================================================
REM batch-name: generationBackup.bat
REM about: 指定された世代数分(日別)、対象フォルダの完全バックアップを取得する。
REM check of operation: Windows Server 2008 R2 SP1 x64, Windows Server 2008 R2 Foundation x64
REM auther: tetsuco
REM create: 2011/10/18
REM change: -
REM ============================================================================
REM ■動作内容
REM   1. バックアップフォルダ直下に、バックアップ実施日の日付名(YYYYMMDD)でフォルダが作成される。(以下、YYYYMMDDフォルダ)
REM   2. YYYYMMDDフォルダ直下にバックアップ対象フォルダの完全バックアップが取得される。
REM   3. バックアップフォルダ直下にYYYYMMDDフォルダが世代管理数よりも多く存在した場合、日付の古い順に削除される。
REM ----------------------------------------------------------------------------
REM ■使用方法
REM   1. 当バッチファイルをタスク・スケジューラにてタスクを新規作成する。
REM   2. タスク・スケジューラにて当バッチファイルを実行したい時刻を設定する。
REM   3. 指定された時刻に当バッチファイルが実行される。
REM ----------------------------------------------------------------------------
REM ■設定変更方法
REM   「要設定: 」とコメントのある箇所が、設定変更する箇所。
REM   1. 30行目: 「set _bkupFolder=」にバックアップ先のフォルダを設定する。
REM   2. 35行目: 「set _generation」に世代管理数を設定する。世代管理数が7の場合は7日保存。
REM   3. 50行目: 「 xcopy」（バックアップ）対象のフォルダを記述。
REM       例）xcopy c:\kyoyu\src1 %_bkupFolder%\%_presentDate%\src1 /E /V /C /I /H /R /O /Y
REM                 バックアップ元: c:\kyoyu\src1
REM                 バックアップ先: %_bkupFolder%\%_presentDate%\src1
REM                 備考: バックアップ元のsrc1をコピーする場合、バックアップ先もsrc1の名前でコピーする
REM ============================================================================

REM ==================================================================
REM 要設定: バックアップフォルダを設定
REM ==================================================================
set _bkupFolder=c:\kyoyu\backup

REM ==================================================================
REM 要設定: 世代管理数(日別)を設定
REM ==================================================================
set _generation=7

REM ==================================================================
REM 現在の日付取得（YYYYMMDD）
REM ==================================================================
set _presentDate=%date:~-10,4%%date:~-5,2%%date:~-2,2%

REM ==================================================================
REM バックアップフォルダの中に、YYYYMMDDの名前でフォルダを作成（世代管理）
REM ==================================================================
md %_bkupFolder%\%_presentDate%

REM ==================================================================
REM 要設定: バックアップ対象のフォルダを、YYYYMMDDフォルダにコピー
REM                 [xcopyのオプション説明]
REM                     /E: ディレクトリまたはサブディレクトリが空であってもコピーする
REM                     /V: ファイルの内容が正しいか検査する
REM                     /C: コピー時のエラーを無視する
REM                     /I: コピー先のディレクトリが存在しない場合は新規にディレクトリを作成する
REM                     /H: 隠しファイルやシステムファイルも全てコピーする
REM                     /R: 読み取り専用属性のファイルも上書きコピーできるようにする
REM                     /K: 通常は解除される読み取り専用属性を維持したままコピーする
REM                     /O: ファイルの所有権やアクセス権限もそのままコピーする
REM                     /Y: 同名のファイルが存在する場合、上書きの確認を行わない
REM ==================================================================
xcopy c:\kyoyu\src1 %_bkupFolder%\%_presentDate%\src1 /E /V /C /I /H /R /K /O /Y
xcopy c:\kyoyu\src2 %_bkupFolder%\%_presentDate%\src2 /E /V /C /I /H /R /K /O /Y

REM ==================================================================
REM バックアップフォルダの中のYYYYMMDDフォルダ数を数える
REM ==================================================================
for /f "delims=" %%i in ('dir /b %_bkupFolder% ^| find /c /v ""') do set _folderNum=%%i

REM ==================================================================
REM 「YYYYMMDDフォルダ数 - 世代管理数」の計算結果を取得
REM ==================================================================
set /a _delFolderNum=_folderNum-_generation

REM ==================================================================
REM 遅延展開をON（FORループの中で、ループ変数を計算に使用するため。尚、変数は%でなく!を使うこと）
REM ==================================================================
setlocal enabledelayedexpansion

REM ==================================================================
REM 世代数を超過した、上から◯つ目までのフォルダを削除する（古いフォルダ順に表示されるため古いに順に削除する）
REM ==================================================================
set _cnt=0

for /f "usebackq delims= eol=" %%i in (`dir /b %_bkupFolder%`) do @(
    if %_delFolderNum% GTR !_cnt! (
        rd /s /q %_bkupFolder%\%%i
    ) else (
        goto break;
    )
    
    set /a _cnt=_cnt+1
)
:break
