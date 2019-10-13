Add-Type -AssemblyName System.Windows.Forms

$frm_main = New-Object system.Windows.Forms.Form
$frm_main.Text = "Quick Sample"
$frm_main.BackColor = "#a5a1a1"
$frm_main.TopMost = $true
$frm_main.Width = 470
$frm_main.Height = 216

$lbl_TextDisplay = New-Object system.windows.Forms.Label
$lbl_TextDisplay.Text = "What happens"
$lbl_TextDisplay.BackColor = "#ba0909"
$lbl_TextDisplay.AutoSize = $true
$lbl_TextDisplay.ForeColor = "#e3dc3b"
$lbl_TextDisplay.Width = 25
$lbl_TextDisplay.Height = 10
$lbl_TextDisplay.location = new-object system.drawing.point(61,43)
$lbl_TextDisplay.Font = "Segoe UI,10,style=Bold"
$frm_main.controls.Add($lbl_TextDisplay)

$btn_Click = New-Object system.windows.Forms.Button
$btn_Click.Text = "Click Here"
$btn_Click.Width = 60
$btn_Click.Height = 30
$btn_Click.Add_Click({
	#add here code triggered by the event
	$lbl_TextDisplay.Text = "Updated via Code"
	$txt_SimpleDisplay.Text = "Also updated via Code"
})
$btn_Click.location = new-object system.drawing.point(317,135)
$btn_Click.Font = "Segoe UI,10"
$frm_main.controls.Add($btn_Click)

$txt_SimpleDisplay = New-Object system.windows.Forms.TextBox
$txt_SimpleDisplay.Width = 100
$txt_SimpleDisplay.Height = 20
$txt_SimpleDisplay.location = new-object system.drawing.point(73,74)
$txt_SimpleDisplay.Font = "Segoe UI,10"
$frm_main.controls.Add($txt_SimpleDisplay)

[void]$frm_main.ShowDialog()
$frm_main.Dispose()