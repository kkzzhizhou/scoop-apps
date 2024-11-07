#  
# WmiExplorer.ps1  
#  
# A GUI WMI explorer and WMI Method Help generator  
#  
# /\/\o\/\/ 2006  
# www.ThePowerShellGuy.com  
#  
# load Forms NameSpace  
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")   
   
#region BuildTheForm build in C# then translated to powershell  
#region Make the form  
$frmMain = new-object Windows.Forms.form    
$frmMain.Size = new-object System.Drawing.Size @(800,600)    
$frmMain.text = "/\/\o\/\/'s PowerShell WMI Explorer"   
#endregion Make the form  
#region Define Used Controls  
$MainMenu = new-object System.Windows.Forms.MenuStrip  
$statusStrip = new-object System.Windows.Forms.StatusStrip  
$FileMenu = new-object System.Windows.Forms.ToolStripMenuItem  
$ToolMenu = new-object System.Windows.Forms.ToolStripMenuItem('&tools')  
$miQuery = new-object System.Windows.Forms.ToolStripMenuItem('&Query (run)')  
$miSelectQuery = new-object System.Windows.Forms.ToolStripMenuItem('&SelectQuery')  
$miSelectQuery.add_Click({$sq | out-propertyGrid;$wmiSearcher.Query = $sq})  
[void]$ToolMenu.DropDownItems.Add($miSelectQuery)  
$miRelatedObjectQuery = new-object System.Windows.Forms.ToolStripMenuItem('&RelatedObjectQuery')  
$miRelatedObjectQuery.add_Click({$roq | out-propertyGrid;$wmiSearcher.Query = $roq})  
[void]$ToolMenu.DropDownItems.Add($miRelatedObjectQuery)  
$miRelationshipQuery = new-object System.Windows.Forms.ToolStripMenuItem('&RelationshipQuery')  
$miRelationshipQuery.add_Click({$rq | out-propertyGrid ;$wmiSearcher.Query = $rq})  
[void]$ToolMenu.DropDownItems.Add($miRelationshipQuery)  
$oq = new-object System.Management.ObjectQuery  
$eq = new-object System.Management.EventQuery  
$sq = new-object System.Management.SelectQuery  
$roq = new-object System.Management.RelatedObjectQuery  
$rq = new-object System.Management.RelationshipQuery  
$wmiSearcher = [wmisearcher]''  
[void]$ToolMenu.DropDownItems.Add($miQuery)  
$miQuery.add_Click({  
    $wmiSearcher | out-propertyGrid  
    $moc = $wmiSearcher.get()  
    $DT =  new-object  System.Data.DataTable  
    $DT.TableName = $lblClass.text  
    $Col =  new-object System.Data.DataColumn  
    $Col.ColumnName = "WmiPath"  
    $DT.Columns.Add($Col)  
    $i = 0  
    $j = 0 ;$lblInstances.Text = $j; $lblInstances.Update()  
    $MOC |  
    ForEach-Object {  
        $j++ ;$lblInstances.Text = $j; $lblInstances.Update()  
        $MO = $_  
         
        # Make a DataRow  
        $DR = $DT.NewRow()  
        $Col =  new-object System.Data.DataColumn  
        $DR.Item("WmiPath") = $mo.__PATH  
        $MO.psbase.properties |  
        ForEach-Object {  
         
            $prop = $_  
             
            If ($i -eq 0)  {  
     
                # Only On First Row make The Headers  
                 
                $Col =  new-object System.Data.DataColumn  
                $Col.ColumnName = $prop.Name.ToString()  
   
                $prop.psbase.Qualifiers |  
                ForEach-Object {  
                    If ($_.Name.ToLower() -eq "key") {  
                        $Col.ColumnName = $Col.ColumnName + "*"  
                    }  
                }  
                $DT.Columns.Add($Col)   
            }  
             
            # fill dataRow   
             
            if ($prop.value -eq $null) {  
                $DR.Item($prop.Name) = "[empty]"  
            } ElseIf ($prop.IsArray) {  
                $DR.Item($prop.Name) =[string]::Join($prop.value ,";")  
            } Else {  
                $DR.Item($prop.Name) = $prop.value  
                #Item is Key try again with *  
                trap{$DR.Item("$($prop.Name)*") = $prop.Value.tostring();continue}  
            }  
        } #end ForEach  
        # Add the row to the DataTable  
         
        $DT.Rows.Add($DR)  
        $i += 1  
    }  
    $DGInstances.DataSource = $DT.psObject.baseobject    
    $status.Text = "Retrieved $j Instances"  
    $status.BackColor = 'YellowGreen'  
    $statusstrip.Update()  
})#$miQuery.add_Click  
 
$miQuit = new-object System.Windows.Forms.ToolStripMenuItem('&quit')  
$miQuit.add_Click({$frmMain.close()})   
$SplitContainer1 = new-object System.Windows.Forms.SplitContainer  
$splitContainer2 = new-object System.Windows.Forms.SplitContainer  
$splitContainer3 = new-object System.Windows.Forms.SplitContainer  
$grpComputer = new-object System.Windows.Forms.GroupBox  
$grpNameSpaces = new-object System.Windows.Forms.GroupBox  
$grpClasses = new-object System.Windows.Forms.GroupBox  
$grpClass = new-object System.Windows.Forms.GroupBox  
$grpInstances = new-object System.Windows.Forms.GroupBox  
$grpStatus = new-object System.Windows.Forms.GroupBox  
$txtComputer = new-object System.Windows.Forms.TextBox  
$btnConnect = new-object System.Windows.Forms.Button  
$btnInstances = new-object System.Windows.Forms.Button  
$tvNameSpaces = new-object System.Windows.Forms.TreeView  
$lvClasses = new-object System.Windows.Forms.ListView  
$clbProperties = new-object System.Windows.Forms.CheckedListBox  
$clbProperties.CheckOnClick = $true  
$lbMethods = new-object System.Windows.Forms.ListBox  
$label1 = new-object System.Windows.Forms.Label  
$label2 = new-object System.Windows.Forms.Label  
$lblServer = new-object System.Windows.Forms.Label  
$lblPath = new-object System.Windows.Forms.Label  
$lblNameSpace = new-object System.Windows.Forms.Label  
$label6 = new-object System.Windows.Forms.Label  
$lblClass = new-object System.Windows.Forms.Label  
$label10 = new-object System.Windows.Forms.Label  
$lblClasses = new-object System.Windows.Forms.Label  
$label12 = new-object System.Windows.Forms.Label  
$lblProperties = new-object System.Windows.Forms.Label  
$label8 = new-object System.Windows.Forms.Label  
$lblMethods = new-object System.Windows.Forms.Label  
$label14 = new-object System.Windows.Forms.Label  
$lblInstances = new-object System.Windows.Forms.Label  
$label16 = new-object System.Windows.Forms.Label  
$dgInstances = new-object System.Windows.Forms.DataGridView  
$TabControl = new-object System.Windows.Forms.TabControl  
$tabPage1 = new-object System.Windows.Forms.TabPage  
$tabInstances = new-object System.Windows.Forms.TabPage  
$rtbHelp = new-object System.Windows.Forms.RichTextBox  
$tabMethods = new-object System.Windows.Forms.TabPage  
$rtbMethods = new-object System.Windows.Forms.RichTextBox  
#endregion Define Used Controls         
#region Suspend the Layout  
$splitContainer1.Panel1.SuspendLayout()  
$splitContainer1.Panel2.SuspendLayout()  
$splitContainer1.SuspendLayout()  
$splitContainer2.Panel1.SuspendLayout()  
$splitContainer2.Panel2.SuspendLayout()  
$splitContainer2.SuspendLayout()  
$grpComputer.SuspendLayout()  
$grpNameSpaces.SuspendLayout()  
$grpClasses.SuspendLayout()  
$splitContainer3.Panel1.SuspendLayout()  
$splitContainer3.Panel2.SuspendLayout()  
$splitContainer3.SuspendLayout()  
$grpClass.SuspendLayout()  
$grpStatus.SuspendLayout()  
$grpInstances.SuspendLayout()  
$TabControl.SuspendLayout()  
$tabPage1.SuspendLayout()  
$tabInstances.SuspendLayout()  
$FrmMain.SuspendLayout()  
#endregion Suspend the Layout  
#region Configure Controls  
[void]$MainMenu.Items.Add($FileMenu)  
[void]$MainMenu.Items.Add($ToolMenu)  
$MainMenu.Location = new-object System.Drawing.Point(0, 0)  
$MainMenu.Name = "MainMenu"  
$MainMenu.Size = new-object System.Drawing.Size(1151, 24)  
$MainMenu.TabIndex = 0  
$MainMenu.Text = "Main Menu"  
#  
# statusStrip1  
#  
$statusStrip.Location = new-object System.Drawing.Point(0, 569)  
$statusStrip.Name = "statusStrip"  
$statusStrip.Size = new-object System.Drawing.Size(1151, 22);  
$statusStrip.TabIndex = 1  
$statusStrip.Text = "statusStrip"  
$splitContainer1.Dock = [System.Windows.Forms.DockStyle]::Fill  
$splitContainer1.Location = new-object System.Drawing.Point(0, 24)  
$splitContainer1.Name = "splitContainer1"  
$splitContainer1.Panel1.Controls.Add($splitContainer2)  
$splitContainer1.Panel2.Controls.Add($splitContainer3)  
$splitContainer1.Size = new-object System.Drawing.Size(1151, 545)  
$splitContainer1.SplitterDistance = 372  
$splitContainer1.TabIndex = 2  
$splitContainer2.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$splitContainer2.Dock = [System.Windows.Forms.DockStyle]::Fill  
$splitContainer2.Location = new-object System.Drawing.Point(0, 0)  
$splitContainer2.Name = "splitContainer2"  
$splitContainer2.Orientation = [System.Windows.Forms.Orientation]::Horizontal  
$splitContainer2.Panel1.BackColor = [System.Drawing.SystemColors]::Control  
$splitContainer2.Panel1.Controls.Add($grpNameSpaces)  
$splitContainer2.Panel1.Controls.Add($btnConnect)  
$splitContainer2.Panel1.Controls.Add($grpComputer)  
$splitContainer2.Panel2.Controls.Add($grpClasses)  
$splitContainer2.Size = new-object System.Drawing.Size(372, 545)  
$splitContainer2.SplitterDistance = 302  
$splitContainer2.TabIndex = 0  
#  
# fileMenu  
#  
[void]$fileMenu.DropDownItems.Add($miQuit)  
$fileMenu.Name = "fileMenu"  
$fileMenu.Size = new-object System.Drawing.Size(35, 20)  
$fileMenu.Text = "&File"  
$grpComputer.Anchor = "top, left, right"  
$grpComputer.Controls.Add($txtComputer)  
$grpComputer.Location = new-object System.Drawing.Point(12, 3)  
$grpComputer.Name = "grpComputer"  
$grpComputer.Size = new-object System.Drawing.Size(340, 57)  
$grpComputer.TabIndex = 0  
$grpComputer.TabStop = $false  
$grpComputer.Text = "Computer"  
$txtComputer.Anchor = "top, left, right"  
$txtComputer.Location = new-object System.Drawing.Point(7, 20)  
$txtComputer.Name = "txtComputer"  
$txtComputer.Size = new-object System.Drawing.Size(244, 20)  
$txtComputer.TabIndex = 0  
$txtComputer.Text = "."  
 
$btnConnect.Anchor = "top, right"  
$btnConnect.Location = new-object System.Drawing.Point(269, 23);  
$btnConnect.Name = "btnConnect"  
$btnConnect.Size = new-object System.Drawing.Size(75, 23)  
$btnConnect.TabIndex = 1  
$btnConnect.Text = "Connect"  
$btnConnect.UseVisualStyleBackColor = $true  
#  
# grpNameSpaces  
#  
$grpNameSpaces.Anchor = "Bottom, top, left, right"  
$grpNameSpaces.Controls.Add($tvNameSpaces)  
$grpNameSpaces.Location = new-object System.Drawing.Point(12, 67)  
$grpNameSpaces.Name = "grpNameSpaces"  
$grpNameSpaces.Size = new-object System.Drawing.Size(340, 217)  
$grpNameSpaces.TabIndex = 2  
$grpNameSpaces.TabStop = $false  
$grpNameSpaces.Text = "NameSpaces"  
#  
# grpClasses  
#  
$grpClasses.Anchor = "Bottom, top, left, right"  
$grpClasses.Controls.Add($lvClasses)  
$grpClasses.Location = new-object System.Drawing.Point(12, 14)  
$grpClasses.Name = "grpClasses"  
$grpClasses.Size = new-object System.Drawing.Size(340, 206)  
$grpClasses.TabIndex = 0  
$grpClasses.TabStop = $False  
$grpClasses.Text = "Classes"  
#  
# tvNameSpaces  
#  
$tvNameSpaces.Anchor = "Bottom, top, left, right"  
$tvNameSpaces.Location = new-object System.Drawing.Point(7, 19)  
$tvNameSpaces.Name = "tvNameSpaces"  
$tvNameSpaces.Size = new-object System.Drawing.Size(325, 184)  
$tvNameSpaces.TabIndex = 0  
#  
# tvClasses  
#  
$lvClasses.Anchor = "Bottom, top, left, right"  
$lvClasses.Location = new-object System.Drawing.Point(7, 19)  
$lvClasses.Name = "tvClasses"  
$lvClasses.Size = new-object System.Drawing.Size(325, 172)  
$lvClasses.TabIndex = 0  
$lvClasses.UseCompatibleStateImageBehavior = $False  
$lvClasses.ShowItemToolTips = $true  
$lvClasses.View = 'Details'  
$colName = $lvClasses.Columns.add('Name')  
$colname.Width = 160  
$colPath = $lvClasses.Columns.add('Description')  
$colname.Width = 260  
$colPath = $lvClasses.Columns.add('Path')  
$colname.Width = 260  
#  
# splitContainer3  
#  
$splitContainer3.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$splitContainer3.Dock = [System.Windows.Forms.DockStyle]::Fill  
$splitContainer3.Location = new-object System.Drawing.Point(0, 0)  
$splitContainer3.Name = "splitContainer3"  
$splitContainer3.Orientation = [System.Windows.Forms.Orientation]::Horizontal  
#  
# splitContainer3.Panel1  
#  
$splitContainer3.Panel1.Controls.Add($grpStatus)  
$splitContainer3.Panel1.Controls.Add($grpClass)  
#  
# splitContainer3.Panel2  
#  
$splitContainer3.Panel2.Controls.Add($TabControl)  
$splitContainer3.Size = new-object System.Drawing.Size(775, 545)  
$splitContainer3.SplitterDistance = 303  
$splitContainer3.TabIndex = 0  
#  
# grpClass  
#  
$grpClass.Anchor = "Bottom, top, left, right"  
$grpClass.Controls.Add($lblInstances)  
$grpClass.Controls.Add($label16)  
$grpClass.Controls.Add($lblMethods)  
$grpClass.Controls.Add($label14)  
$grpClass.Controls.Add($lblProperties)  
$grpClass.Controls.Add($label8)  
$grpClass.Controls.Add($lblClass)  
$grpClass.Controls.Add($label10)  
$grpClass.Controls.Add($lbMethods)  
$grpClass.Controls.Add($clbProperties)  
$grpClass.Controls.Add($btnInstances)  
$grpClass.Location = new-object System.Drawing.Point(17, 86)  
$grpClass.Name = "grpClass"  
$grpClass.Size = new-object System.Drawing.Size(744, 198)  
$grpClass.TabIndex = 0  
$grpClass.TabStop = $False  
$grpClass.Text = "Class"  
#  
# btnInstances  
#  
$btnInstances.Anchor = "Bottom, Left"  
$btnInstances.Location = new-object System.Drawing.Point(6, 169);  
$btnInstances.Name = "btnInstances";  
$btnInstances.Size = new-object System.Drawing.Size(96, 23);  
$btnInstances.TabIndex = 0;  
$btnInstances.Text = "Get Instances";  
$btnInstances.UseVisualStyleBackColor = $true  
#  
# grpStatus  
#  
$grpStatus.Anchor = "Top,Left,Right"  
$grpStatus.Controls.Add($lblClasses)  
$grpStatus.Controls.Add($label12)  
$grpStatus.Controls.Add($lblNameSpace)  
$grpStatus.Controls.Add($label6)  
$grpStatus.Controls.Add($lblPath)  
$grpStatus.Controls.Add($lblServer)  
$grpStatus.Controls.Add($label2)  
$grpStatus.Controls.Add($label1)  
$grpStatus.Location = new-object System.Drawing.Point(17, 3)  
$grpStatus.Name = "grpStatus"  
$grpStatus.Size = new-object System.Drawing.Size(744, 77)  
$grpStatus.TabIndex = 1  
$grpStatus.TabStop = $False  
$grpStatus.Text = "Status"  
#  
# label1  
#  
$label1.AutoSize = $true  
$label1.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label1.Location = new-object System.Drawing.Point(7, 20)  
$label1.Name = "label1"  
$label1.Size = new-object System.Drawing.Size(62, 16)  
$label1.TabIndex = 0  
$label1.Text = "Server :"  
#  
# label2  
#  
$label2.AutoSize = $true  
$label2.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label2.Location = new-object System.Drawing.Point(7, 41)  
$label2.Name = "label2"  
$label2.Size = new-object System.Drawing.Size(51, 16)  
$label2.TabIndex = 1  
$label2.Text = "Path  :"  
#  
# lblServer  
#  
$lblServer.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblServer.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblServer.Location = new-object System.Drawing.Point(75, 20)  
$lblServer.Name = "lblServer"  
$lblServer.Size = new-object System.Drawing.Size(144, 20)  
$lblServer.TabIndex = 2  
#  
# lblPath  
#  
$lblPath.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblPath.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblPath.Location = new-object System.Drawing.Point(75, 40)  
$lblPath.Name = "lblPath"  
$lblPath.Size = new-object System.Drawing.Size(567, 20)  
$lblPath.TabIndex = 3  
#  
# lblNameSpace  
#  
$lblNameSpace.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblNameSpace.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblNameSpace.Location = new-object System.Drawing.Point(337, 20)  
$lblNameSpace.Name = "lblNameSpace"  
$lblNameSpace.Size = new-object System.Drawing.Size(144, 20)  
$lblNameSpace.TabIndex = 5  
#  
# label6  
#  
$label6.AutoSize = $true  
$label6.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label6.Location = new-object System.Drawing.Point(229, 20)  
$label6.Name = "label6"  
$label6.Size = new-object System.Drawing.Size(102, 16)  
$label6.TabIndex = 4  
$label6.Text = "NameSpace :"  
#  
# lblClass  
#  
$lblClass.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblClass.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblClass.Location = new-object System.Drawing.Point(110, 26)  
$lblClass.Name = "lblClass"  
$lblClass.Size = new-object System.Drawing.Size(159, 20)  
$lblClass.TabIndex = 11  
#  
# label10  
#  
$label10.AutoSize = $true  
$label10.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label10.Location = new-object System.Drawing.Point(6, 26)  
$label10.Name = "label10"  
$label10.Size = new-object System.Drawing.Size(55, 16)  
$label10.TabIndex = 10  
$label10.Text = "Class :"  
#  
# lblClasses  
#  
$lblClasses.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblClasses.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblClasses.Location = new-object System.Drawing.Point(595, 21)  
$lblClasses.Name = "lblClasses"  
$lblClasses.Size = new-object System.Drawing.Size(47, 20)  
$lblClasses.TabIndex = 9  
#  
# label12  
#  
$label12.AutoSize = $true  
$label12.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label12.Location = new-object System.Drawing.Point(487, 21)  
$label12.Name = "label12"  
$label12.Size = new-object System.Drawing.Size(76, 16)  
$label12.TabIndex = 8  
$label12.Text = "Classes  :"  
#  
# clbProperties  
#  
$clbProperties.Anchor = "Bottom, top,left"  
$clbProperties.FormattingEnabled = $true  
$clbProperties.Location = new-object System.Drawing.Point(510, 27)  
$clbProperties.Name = "clbProperties"  
$clbProperties.Size = new-object System.Drawing.Size(220, 160)  
$clbProperties.TabIndex = 1  
#  
# lbMethods  
#  
$lbMethods.Anchor = "Bottom, top, Left"  
$lbMethods.FormattingEnabled = $true  
$lbMethods.Location = new-object System.Drawing.Point(280, 27)  
$lbMethods.Name = "lbMethods"  
$lbMethods.Size = new-object System.Drawing.Size(220, 160)  
$lbMethods.TabIndex = 2  
#  
# lblProperties  
#  
$lblProperties.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblProperties.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblProperties.Location = new-object System.Drawing.Point(110, 46)  
$lblProperties.Name = "lblProperties"  
$lblProperties.Size = new-object System.Drawing.Size(119, 20)  
$lblProperties.TabIndex = 13  
#  
# label8  
#  
$label8.AutoSize = $true  
$label8.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label8.Location = new-object System.Drawing.Point(6, 46)  
$label8.Name = "label8"  
$label8.Size = new-object System.Drawing.Size(88, 16)  
$label8.TabIndex = 12  
$label8.Text = "Properties :"  
#  
# lblMethods  
#  
$lblMethods.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblMethods.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblMethods.Location = new-object System.Drawing.Point(110, 66)  
$lblMethods.Name = "lblMethods"  
$lblMethods.Size = new-object System.Drawing.Size(119, 20)  
$lblMethods.TabIndex = 15  
#  
# label14  
#  
$label14.AutoSize = $true  
$label14.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label14.Location = new-object System.Drawing.Point(6, 66)  
$label14.Name = "label14"  
$label14.Size = new-object System.Drawing.Size(79, 16)  
$label14.TabIndex = 14  
$label14.Text = "Methods  :"  
#  
# lblInstances  
#  
$lblInstances.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
$lblInstances.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$lblInstances.Location = new-object System.Drawing.Point(110, 86)  
$lblInstances.Name = "lblInstances"  
$lblInstances.Size = new-object System.Drawing.Size(119, 20)  
$lblInstances.TabIndex = 17  
#  
# label16  
#  
$label16.AutoSize = $true  
$label16.Font = new-object System.Drawing.Font("Microsoft Sans Serif",9.75 ,[System.Drawing.FontStyle]::Bold)  
$label16.Location = new-object System.Drawing.Point(6, 86)  
$label16.Name = "label16"  
$label16.Size = new-object System.Drawing.Size(82, 16)  
$label16.TabIndex = 16  
$label16.Text = "Instances :"  
#  
# grpInstances  
#  
$grpInstances.Anchor = "Bottom, top, left, right"  
$grpInstances.Controls.Add($dgInstances)  
$grpInstances.Location = new-object System.Drawing.Point(17, 17)  
$grpInstances.Name = "grpInstances"  
$grpInstances.Size = new-object System.Drawing.Size(744, 202)  
$grpInstances.TabIndex = 0  
$grpInstances.TabStop = $False  
$grpInstances.Text = "Instances"  
#  
# dgInstances  
#  
$dgInstances.Anchor = "Bottom, top, left, right"  
$dgInstances.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize  
$dgInstances.Location = new-object System.Drawing.Point(10, 19)  
$dgInstances.Name = "dgInstances"  
$dgInstances.Size = new-object System.Drawing.Size(728, 167)  
$dgInstances.TabIndex = 0  
$dginstances.ReadOnly = $true  
# TabControl  
#  
$TabControl.Controls.Add($tabPage1)  
$TabControl.Controls.Add($tabInstances)  
$TabControl.Controls.Add($tabMethods)  
$TabControl.Dock = [System.Windows.Forms.DockStyle]::Fill  
$TabControl.Location = new-object System.Drawing.Point(0, 0)  
$TabControl.Name = "TabControl"  
$TabControl.SelectedIndex = 0  
$TabControl.Size = new-object System.Drawing.Size(771, 234)  
$TabControl.TabIndex = 0  
#  
# tabPage1  
#  
$tabPage1.Controls.Add($rtbHelp)  
$tabPage1.Location = new-object System.Drawing.Point(4, 22)  
$tabPage1.Name = "tabPage1"  
$tabPage1.Padding = new-object System.Windows.Forms.Padding(3)  
$tabPage1.Size = new-object System.Drawing.Size(763, 208)  
$tabPage1.TabIndex = 0  
$tabPage1.Text = "Help"  
$tabPage1.UseVisualStyleBackColor = $true  
#  
# tabInstances  
#  
$tabInstances.Controls.Add($grpInstances)  
$tabInstances.Location = new-object System.Drawing.Point(4, 22)  
$tabInstances.Name = "tabInstances"  
$tabInstances.Padding = new-object System.Windows.Forms.Padding(3)  
$tabInstances.Size = new-object System.Drawing.Size(763, 208)  
$tabInstances.TabIndex = 1  
$tabInstances.Text = "Instances"  
$tabInstances.UseVisualStyleBackColor = $true  
#  
# richTextBox1  
#  
$rtbHelp.Dock = [System.Windows.Forms.DockStyle]::Fill  
$rtbHelp.Location = new-object System.Drawing.Point(3, 3)  
$rtbHelp.Name = "richTextBox1"  
$rtbHelp.Size = new-object System.Drawing.Size(757, 202)  
$rtbHelp.TabIndex = 0  
$rtbHelp.Text = ""  
#  
# tabMethods  
#  
$tabMethods.Location = new-object System.Drawing.Point(4, 22)  
$tabMethods.Name = "tabMethods"  
$tabMethods.Padding = new-object System.Windows.Forms.Padding(3)  
$tabMethods.Size = new-object System.Drawing.Size(763, 208)  
$tabMethods.TabIndex = 2  
$tabMethods.Text = "Methods"  
$tabMethods.UseVisualStyleBackColor = $true  
 
        $rtbMethods.Dock = [System.Windows.Forms.DockStyle]::Fill  
        $rtbMethods.Font = new-object System.Drawing.Font("Lucida Console",8 )  
        $rtbMethods.DetectUrls = $false  
        $tabMethods.controls.add($rtbMethods)  
         
#endregion Configure Controls  
# Configure  Main Form  
#region frmMain  
 
#  
$frmMain.AutoScaleDimensions = new-object System.Drawing.SizeF(6, 13)  
$frmMain.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font  
$frmMain.ClientSize = new-object System.Drawing.Size(1151, 591)  
$frmMain.Controls.Add($splitContainer1)  
$frmMain.Controls.Add($statusStrip)  
$frmMain.Controls.Add($MainMenu)  
$frmMain.MainMenuStrip = $mainMenu  
$FrmMain.Name = "frmMain"  
$FrmMain.Text = "/\/\o\/\/ PowerShell WMI Browser"  
$mainMenu.ResumeLayout($false)  
$mainMenu.PerformLayout()  
$MainMenu.ResumeLayout($false)  
$MainMenu.PerformLayout()  
$splitContainer1.Panel1.ResumeLayout($false)  
$splitContainer1.Panel2.ResumeLayout($false)  
$splitContainer1.ResumeLayout($false)  
$splitContainer2.Panel1.ResumeLayout($false)  
$splitContainer2.Panel2.ResumeLayout($false)  
$splitContainer2.ResumeLayout($false)  
$grpComputer.ResumeLayout($false)  
$grpComputer.PerformLayout()  
$grpNameSpaces.ResumeLayout($false)  
$grpClasses.ResumeLayout($false)  
$splitContainer3.Panel1.ResumeLayout($false)  
$splitContainer3.Panel2.ResumeLayout($false)  
$splitContainer3.ResumeLayout($false)  
$grpClass.ResumeLayout($false)  
$grpClass.PerformLayout()  
$grpStatus.ResumeLayout($false)  
$grpStatus.PerformLayout()  
$grpInstances.ResumeLayout($false)  
$TabControl.ResumeLayout($false)  
$tabPage1.ResumeLayout($false)  
$tabInstances.ResumeLayout($false)  
$frmMain.ResumeLayout($false)  
$FrmMain.PerformLayout()  
$status = new-object System.Windows.Forms.ToolStripStatusLabel  
$status.BorderStyle = 'SunkenInner'  
$status.BorderSides = 'All'  
$status.Text = "Not Connected"  
[void]$statusStrip.Items.add($status)  
$slMessage = new-object System.Windows.Forms.ToolStripStatusLabel  
$slMessage.BorderStyle = 'SunkenInner'  
$slMessage.BorderSides = 'All'  
$slMessage.Text = ""  
[void]$statusStrip.Items.add($slMessage)  
#endregion frmMain  
#endregion  
#region Helper Functions  
Function out-PropertyGrid {  
  Param ($Object,[switch]$noBase,[Switch]$array)  
  $PsObject = $null  
  if ($object) {  
      $PsObject = $object  
  }Else{  
     if ($Array.IsPresent) {  
         $PsObject = @()  
         $input |ForEach-Object {$PsObject += $_}  
     }Else{  
         $input |ForEach-Object {$PsObject = $_}  
     }  
  }  
  if ($PsObject){  
      $form = new-object Windows.Forms.Form   
      $form.Size = new-object Drawing.Size @(600,600)   
      $PG = new-object Windows.Forms.PropertyGrid   
      $PG.Dock = 'Fill'   
      $form.text = "$psObject"   
      if ($noBase.IsPresent) {"no";  
          $PG.selectedobject = $psObject   
      }Else{  
          $PG.selectedobject = $psObject.PsObject.baseobject   
      }   
      $form.Controls.Add($PG)   
      $Form.Add_Shown({$form.Activate()})    
      $form.showdialog()  
  }  
} #Function out-PropertyGrid  
Function Update-Status {  
  $script:computer = $Script:NameSpaces.__SERVER  
  $txtComputer.Text = $script:computer  
  $lblPath.Text = $Script:NameSpaces.__PATH                                 
  $lblProperties.Text = $Script:NameSpaces.__PROPERTY_COUNT                                 
  $lblClass.Text = $Script:NameSpaces.__RELPATH                                     
  $lblServer.Text = $script:Computer  
  $lblnamespace.Text = $Script:NameSpaces.__NAMESPACE  
} # Function Update-Status  
Function Set-StatusBar ([Drawing.Color]$Color,$Text) {  
  $status.BackColor = $color  
  $status.Text = $text  
  $statusstrip.Update()    
}  
#endregion Helper Functions  
#################### Main ###############################  
#region Global Variables  
$FontBold = new-object System.Drawing.Font("Microsoft Sans Serif",8,[Drawing.FontStyle]'Bold' )  
$fontNormal = new-object System.Drawing.Font("Microsoft Sans Serif",8,[Drawing.FontStyle]'Regular')  
$fontCode = new-object System.Drawing.Font("Lucida Console",8 )  
# Create Script Variables for WMI Connection  
$Script:ConnectionOptions = new-object System.Management.ConnectionOptions  
$script:WmiConnection = new-object system.management.ManagementScope  
$script:WmiClass = [wmiClass]''  
# NamespaceCaching , Make HashTable to store Treeview Items  
$script:nsc = @{}  
# Make DataSet for secondary Cache  
$Script:dsCache = new-object data.dataset  
if (-not ${Global:WmiExplorer.dtClasses}){  
    ${Global:WmiExplorer.dtClasses} = new-object data.datatable  
    [VOID](${Global:WmiExplorer.dtClasses}.Columns.add('Path',[string]))  
    [VOID](${Global:WmiExplorer.dtClasses}.Columns.add('Namespace',[string]))  
    [VOID](${Global:WmiExplorer.dtClasses}.Columns.add('name',[string]))  
    [VOID](${Global:WmiExplorer.dtClasses}.Columns.add('Description',[string]))  
    ${Global:WmiExplorer.dtClasses}.tablename = 'Classes'  
}  
#endregion  
#region Control Handlers  
# Add Delegate Scripts to finetune the WMI Connection objects to the events of the controls  
$slMessage.DoubleClickEnabled = $true  
$slMessage.add_DoubleClick({$error[0] | out-PropertyGrid})  
$lblNameSpace.add_DoubleClick({$script:WmiConnection | out-PropertyGrid})  
$lblserver.add_DoubleClick({$Script:ConnectionOptions | out-PropertyGrid})  
$lblClass.add_DoubleClick({$script:WmiClass | out-PropertyGrid})  
 
$btnConnect.add_click({ConnectToComputer})  
$TVNameSpaces.add_DoubleClick({GetClassesFromNameSpace})  
$lvClasses.Add_DoubleClick({GetWmiClass})  
$btnInstances.add_Click({GetWmiInstances})  
$dgInstances.add_DoubleClick({OutputWmiInstance})  
$lbMethods.Add_DoubleClick({GetWmiMethod})  
$clbProperties.add_Click({  
  trap{Continue}  
  $DGInstances.Columns.Item(($this.SelectedItem)).visible = -not $clbProperties.GetItemChecked($this.SelectedIndex)  
})  
$TVNameSpaces.add_AfterSelect({  
    if ($this.SelectedNode.name -ne $Computer){  
        $lblPath.Text = "$($script:WmiConnection.path.path.replace('\root',''))\$($this.SelectedNode.Text)"   
    }  
   
    $lblProperties.Text = $Script:NameSpaces.__PROPERTY_COUNT                                 
    $lblServer.Text = $Script:NameSpaces.__SERVER  
    $lblnamespace.Text = $this.SelectedNode.Text  
    if ($this.SelectedNode.tag -eq "NotEnumerated") {  
        (new-object system.management.managementClass(  
                "$($script:WmiConnection.path.path.replace('\root',''))\$($this.SelectedNode.Text):__NAMESPACE")  
        ).PSbase.getInstances() | Sort-Object $_.name |  
        ForEach-Object {  
          $TN = new-object System.Windows.Forms.TreeNode  
          $TN.Name = $_.name  
          $TN.Text = ("{0}\{1}" -f $_.__NameSpace,$_.name)  
          $TN.tag = "NotEnumerated"  
          $this.SelectedNode.Nodes.Add($TN)  
        }  
         
        # Set tag to show this node is already enumerated  
        $this.SelectedNode.tag = "Enumerated"  
    }  
    $mp = ("{0}\{1}" -f $script:WmiConnection.path.path.replace('\root','') , $this.SelectedNode.text)  
    $lvClasses.Items.Clear()  
    if($Script:nsc.Item("$mp")){ # in Namespace cache  
        $lvClasses.BeginUpdate()  
        $lvClasses.Items.AddRange(($nsc.Item( "$mp")))  
        $status.Text = "$mp : $($lvClasses.Items.count) Classes"  
        $lvClasses.EndUpdate()  
        $lblClasses.Text = $lvClasses.Items.count  
    } else {  
        if(${Global:WmiExplorer.dtClasses}.Select("Namespace='$mp'")){ # In DataTable Cache  
            $status.BackColor = 'beige'  
            $status.Text = "$mp : Classes in Cache, DoubleClick NameSpace to retrieve Classes"  
        } else {  
            $status.BackColor = 'LightSalmon'  
            $status.Text = "$mp : Classes not recieved yet, DoubleClick NameSpace to retrieve Classes"  
        }  
    }  
}) # $TVNameSpaces.add_AfterSelect  
#endregion  
#region Processing Functions  
#region ConnectToComputer  
# Connect to Computer  
Function ConnectToComputer {  
     
    $computer = $txtComputer.Text  
    Set-StatusBar 'beige' "Connecting to : $computer"  
     
    # Try to Connect to Computer  
    &{  
        trap {  
            Set-StatusBar 'Red' "Connecting to : $computer Failed"  
            $slMessage.Text = "$_.message"  
            Continue  
        }  
        &{  
            # Connect to WMI root  
             
            $script:WmiConnection.path = "\\$computer\root"  
            $script:WmiConnection.options = $Script:ConnectionOptions  
            $script:WmiConnection.Connect()  
             
            # Get Avaiable NameSpaces  
     
            $opt = new-object system.management.ObjectGetOptions  
            $opt.UseAmendedQualifiers = $true  
            $Script:NameSpaces = new-object System.Management.ManagementClass(  
                $script:WmiConnection,[Management.ManagementPath]'__Namespace',$opt  
            )  
            Update-Status  
            # Create a TreeNode for the WMI Root found  
            $computer = $txtComputer.Text  
            $TNRoot = new-object System.Windows.Forms.TreeNode("Root")  
            $TNRoot.Name = $Computer  
            $TNRoot.Text = $lblPath.Text  
            $TNRoot.tag = "Enumerated"  
             
            # Create NameSpaces List  
             
            $Script:NameSpaces.PSbase.getInstances() | Sort-Object $_.name |  
            ForEach-Object {  
                $TN = new-object System.Windows.Forms.TreeNode  
                $TN.Name = $_.name  
                $TN.Text = ("{0}\{1}" -f $_.__NameSpace,$_.name)  
                $TN.tag = "NotEnumerated"  
                [void]$TNRoot.Nodes.Add($TN)  
            }  
            # Add to Treeview  
            $tvNameSpaces.Nodes.clear()  
            [void]$TVNamespaces.Nodes.Add($TNRoot)  
             
            # update StatusBar  
            Set-StatusBar 'YellowGreen' "Connected to : $computer"  
        }  
    }  
} # ConnectToComputer  
#endregion  
#region GetClasseFromNameSpace  
# Get Classes on DoubleClick on Namespace in TreeView  
Function GetClassesFromNameSpace {  
  if ($this.SelectedNode.name -ne $script:computer){  
    # Connect to WMI Namespace  
         
    $mp = ("{0}\{1}" -f $script:WmiConnection.path.path.replace('\root','') , $this.SelectedNode.text)  
      # Update Status  
         
      $lvClasses.BeginUpdate()  
      $lvClasses.Items.Clear()  
      $i = 0 ;$lblClasses.Text = $i; $lblclasses.Update()  
    if($Script:nsc.Item("$mp")){ #in Namespace Cache, so just attach to ListView again  
         
        $lvClasses.Items.AddRange(($nsc.Item( "$mp")))  
        # $lvClasses.Items.AddRange(([System.Windows.Forms.ListViewItem[]]($nsc.Item( "$mp") |  
            # where {$_.name -like 'win32_*'})))  
        $status.Text = "$mp : $($lvClasses.Items.count) Classes"  
        $i = $lvClasses.Items.count  
    } else { #Not In NameSpace Cache  
      if(${Global:WmiExplorer.dtClasses}.Select("Namespace = '$mp'")){ # In DataTable cache, so get from there  
        $status.Text = "loading cache from $($this.SelectedNode.name)"  
        $statusStrip.Update()  
        ${Global:WmiExplorer.dtClasses}.Select("Namespace = '$mp'") |  
        foreach {  
            $i++  
            $LI = New-Object system.Windows.Forms.ListViewItem  
            $li.Name = $_.name  
            $li.Text = $_.name  
            $li.SubItems.add($_.description)  
            $li.SubItems.add($_.path)  
            $li.ToolTipText = ($_.description)  
            $lvClasses.Items.add($li)  
            $status.Text = "$mp : $($lvClasses.Items.count) Classes"  
            $lblClasses.Text = $lvClasses.Items.count  
        }  
      } else { # Not in any Cache , Load WMI Classes  
        Set-StatusBar 'Khaki' "Getting Classes from $($this.SelectedNode.name)"  
        $mc = new-object System.Management.ManagementClass($mp,$opt)  
        $eo = New-Object system.management.EnumerationOptions  
        $eo.EnumerateDeep = $true  
        $eo.UseAmendedQualifiers = $true  
        $Mc.psbase.GetSubclasses($eo) |  
        ForEach-Object  {  
            $i++ ; if ($i%10 -eq 0){$lblClasses.Text = $i;$lblclasses.Update() }  
            Trap{$script:Description = "[Empty]";continue}  
            $script:description = $_.psbase.Qualifiers.item("description").value  
            ${Global:WmiExplorer.dtClasses}.Rows.Add($_.__path,$mp,$_.name,$description)  
            $LI = New-Object system.Windows.Forms.ListViewItem  
            $li.Name = $_.name  
            $li.Text = $_.name  
            $li.SubItems.add($description)  
            $li.SubItems.add($_.__path)  
            $li.ToolTipText = $description  
            $lvClasses.Items.add($li)  
        }  
        $status.Text = "Ready, Retrieved $i Classes from $mp"  
      } #if(${Global:WmiExplorer.dtClasses}.Select("Namespace = '$mp'"))  
      $lvClasses.Sorting = 'Ascending'  
      $lvClasses.Sort()  
      $script:nsc.Add($mp,(([System.Windows.Forms.ListViewItem[]]($lvClasses.Items)).clone()))  
       
    }  
    $lvClasses.EndUpdate()  
    $this.selectedNode.BackColor = 'AliceBlue'  
    $lblClasses.Text = $i;$lblclasses.Update()  
    $status.BackColor = 'YellowGreen'  
    $statusStrip.Update()  
  } #if($Script:nsc.Item("$mp"))  
     
} # GetClassesFromNameSpace  
#endregion  
#region GetWmiClass  
Function GetWmiClass {  
    # Update Status  
     
    $status.Text = "Retrieving Class"  
    $status.BackColor = 'Khaki'  
    $statusstrip.Update()  
    $lblClass.Text =  $this.SelectedItems |ForEach-Object {$_.name}  
    $lblPath.text = $this.SelectedItems |ForEach-Object {"$($_.SubItems[2].text)"}  
     
    # Add HelpText  
     
    $rtbHelp.Text = ""  
    $rtbHelp.selectionFont  = $fontBold  
    $rtbHelp.appendtext("$($lblClass.Text)`n`n")  
    $rtbHelp.selectionFont  = $fontNormal  
    $rtbHelp.appendtext(($this.SelectedItems |ForEach-Object {"$($_.SubItems[1].text)"}))  
    $rtbHelp.appendtext("`n")  
    $path = $lblPath.text  
     
    $opt = new-object system.management.ObjectGetOptions  
    $opt.UseAmendedQualifiers = $true  
     
    $script:WmiClass = new-object system.management.ManagementClass($path,$opt)  
    # Add Property Help  
     
    $rtbHelp.selectionFont  = $fontBold  
    $rtbHelp.appendtext("`n$($lblClass.Text) Properties :`n`n")  
    $rtbHelp.selectionFont  = $fontNormal  
     
    $i = 0 ;$lblProperties.Text = $i; $lblProperties.Update()  
    $clbproperties.Items.Clear()  
    $clbProperties.Items.add('WmiPath',$False)  
             
    $script:WmiClass.psbase.properties |  
    ForEach-Object {  
        $i++ ;$lblProperties.Text = $i; $lblProperties.Update()  
        $clbProperties.Items.add($_.name,$true)  
        $rtbHelp.selectionFont  = $fontBold  
        $rtbHelp.appendtext("$($_.Name) :`n" )  
        &{  
            Trap {$rtbHelp.appendtext("[Empty]");Continue}  
            $rtbHelp.appendtext($_.psbase.Qualifiers["description"].value)  
        }  
        $rtbHelp.appendtext("`n`n")  
    } # ForEach-Object  
     
    # Create Method Help  
    $rtbHelp.selectionFont  = $fontBold  
    $rtbHelp.appendtext( "$($lblClass.Text) Methods :`n`n" )  
    $i = 0 ;$lblMethods.Text = $i; $lblMethods.Update()  
    $lbmethods.Items.Clear()  
     
    $script:WmiClass.psbase.Methods |  
    ForEach-Object {  
        $i++ ;$lblMethods.Text = $i; $lblMethods.Update()  
        $lbMethods.Items.add($_.name)  
        $rtbHelp.selectionFont  = $fontBold  
        $rtbHelp.appendtext("$($_.Name) :`n")  
        &{  
            Trap {$rtbHelp.Text += "[Empty]"}  
            $rtbHelp.appendtext($_.Qualifiers["description"].value)  
        }  
        $rtbHelp.appendtext("`n`n" )  
    } #ForEach-Object  
      
    $tabControl.SelectedTab = $tabpage1  
    $status.Text = "Retrieved Class"  
    $status.BackColor = 'YellowGreen'  
    $statusstrip.Update()  
} # GetWmiClass  
#endregion  
#region GetWmiInstances  
Function GetWmiInstances {  
    $status.Text = "Getting Instances for $($lblClass.text)"  
    $status.BackColor = 'Red'  
    $statusstrip.Update()  
    $tabControl.SelectedTab = $tabInstances  
    $MC = new-object system.management.ManagementClass $lblPath.text  
    $MOC = $MC.PSbase.getInstances()  
     
    #trap{"Class Not found";break}  
     
    $DT =  new-object  System.Data.DataTable  
    $DT.TableName = $lblClass.text  
    $Col =  new-object System.Data.DataColumn  
    $Col.ColumnName = "WmiPath"  
    $DT.Columns.Add($Col)  
    $i = 0  
    $j = 0 ;$lblInstances.Text = $j; $lblInstances.Update()  
    $MOC | ForEach-Object {  
        $j++ ;$lblInstances.Text = $j; $lblInstances.Update()  
        $MO = $_  
         
        # Make a DataRow  
        $DR = $DT.NewRow()  
        $Col =  new-object System.Data.DataColumn  
         
        $DR.Item("WmiPath") = $mo.__PATH  
        $MO.psbase.properties |  
        ForEach-Object {  
            $prop = $_  
            If ($i -eq 0)  {  
     
                # Only On First Row make The Headers  
                 
                $Col =  new-object System.Data.DataColumn  
                $Col.ColumnName = $prop.Name.ToString()  
                $prop.psbase.Qualifiers | ForEach-Object {  
                    If ($_.Name.ToLower() -eq "key") {  
                        $Col.ColumnName = $Col.ColumnName + "*"  
                    }  
                }  
                $DT.Columns.Add($Col)   
            }  
             
            # fill dataRow   
             
            if ($prop.value -eq $null) {  
                $DR.Item($prop.Name) = "[empty]"  
            }  
            ElseIf ($prop.IsArray) {  
                                $ofs = ";"  
                $DR.Item($prop.Name) ="$($prop.value)"  
                                $ofs = $null  
            }  
            Else {  
                $DR.Item($prop.Name) = $prop.value  
                #Item is Key try again with *  
                trap{$DR.Item("$($prop.Name)*") = $prop.Value.tostring();continue}  
            }  
        }  
        # Add the row to the DataTable  
        $DT.Rows.Add($DR)  
        $i += 1  
    }  
    $DGInstances.DataSource = $DT.psObject.baseobject  
        $DGInstances.Columns.Item('WmiPath').visible =  $clbProperties.GetItemChecked(0)   
    $status.Text = "Retrieved $j Instances"  
    $status.BackColor = 'YellowGreen'  
    $statusstrip.Update()  
} # GetWmiInstances  
#endregion  
#region OutputWmiInstance  
Function OutputWmiInstance {  
    if ( $this.SelectedRows.count -eq 1 ) {  
        if (-not $Script:InstanceTab) {$Script:InstanceTab = new-object System.Windows.Forms.TabPage  
            $Script:InstanceTab.Name = 'Instance'  
            $Script:rtbInstance = new-object System.Windows.Forms.RichTextBox  
            $Script:rtbInstance.Dock = [System.Windows.Forms.DockStyle]::Fill  
            $Script:rtbInstance.Font = $fontCode  
            $Script:rtbInstance.DetectUrls = $false  
            $Script:InstanceTab.controls.add($Script:rtbInstance)  
            $TabControl.TabPages.add($Script:InstanceTab)  
        }  
        $Script:InstanceTab.Text = "Instance = $($this.SelectedRows | ForEach-Object {$_.DataboundItem.wmiPath.split(':')[1]})" 
        $Script:rtbInstance.Text = $this.SelectedRows |ForEach-Object {$_.DataboundItem |Format-List  * | out-String -width 1000 } 
        $tabControl.SelectedTab = $Script:InstanceTab  
    }  
}  # OutputWmiInstance  
#endregion  
#region GetWmiMethod  
Function GetWmiMethod {  
    $WMIMethod = $this.SelectedItem  
    $WmiClassName = $script:WmiClass.__Class  
    $tabControl.SelectedTab = $tabMethods  
    #$rtbmethods.ForeColor = 'Green'  
    $rtbMethods.Font  = new-object System.Drawing.Font("Microsoft Sans Serif",8)  
    $rtbMethods.text = ""  
    $rtbMethods.selectionFont  = $fontBold  
     
    $rtbMethods.AppendText(("{1} Method : {0} `n" -f $this.SelectedItem , $script:WmiClass.__Class))  
    $rtbMethods.AppendText("`n")  
    $rtbMethods.selectionFont  = $fontBold  
    $rtbMethods.AppendText("OverloadDefinitions:`n")  
    $rtbMethods.AppendText("$($script:WmiClass.$WMIMethod.OverloadDefinitions)`n`n")  
    $Qualifiers=@()  
    $script:WmiClass.psbase.Methods[($this.SelectedItem)].Qualifiers | ForEach-Object {$qualifiers += $_.name}  
    #$rtbMethods.AppendText( "$qualifiers`n" )  
    $static = $Qualifiers -Contains "Static"   
    $rtbMethods.selectionFont  = $fontBold  
    $rtbMethods.AppendText( "Static : $static`n" )  
    If ($static) {   
         $rtbMethods.AppendText( "A Static Method does not an Instance to act upon`n`n" )  
         $rtbMethods.AppendText("`n")  
     
         $rtbMethods.SelectionColor = 'Green'  
         $rtbMethods.SelectionFont = $fontCode  
         $rtbMethods.AppendText("# Sample Of Connecting to a WMI Class`n`n")  
         $rtbMethods.SelectionColor = 'Black'  
         $rtbMethods.SelectionFont = $fontCode  
         $SB = new-Object text.stringbuilder  
         $SB = $SB.Append('$Computer = "') ; $SB = $SB.AppendLine(".`"")  
         $SB = $SB.Append('$Class = "') ; $SB = $SB.AppendLine("$WmiClassName`"")    
         $SB = $SB.Append('$Method = "') ; $SB = $SB.AppendLine("$WmiMethod`"`n")  
         $SB = $SB.AppendLine('$MC = [WmiClass]"\\$Computer\' + "$($script:WmiClass.__NAMESPACE)" + ':$Class"')    
         #$SB = $SB.Append('$MP.Server = "') ; $SB = $SB.AppendLine("$($MP.Server)`"")    
         #$SB = $SB.Append('$MP.NamespacePath = "') ; $SB = $SB.AppendLine("$($script:WmiClass.__NAMESPACE)`"")    
         #$SB = $SB.AppendLine('$MP.ClassName = $Class')  
         $SB = $SB.AppendLine("`n")     
         #$SB = $SB.AppendLine('$MC = new-object system.management.ManagementClass($MP)')    
         $rtbMethods.AppendText(($sb.tostring()))  
         $rtbMethods.SelectionColor = 'Green'  
         $rtbMethods.SelectionFont = $fontCode  
         $rtbMethods.AppendText("# Getting information about the methods`n`n")  
         $rtbMethods.SelectionColor = 'Black'  
         $rtbMethods.SelectionFont = $fontCode  
         $rtbMethods.AppendText(  
             '$mc' + "`n" +  
             '$mc | Get-Member -membertype Method' + "`n" +  
             "`$mc.$WmiMethod"  
         )  
    } Else {  
         $rtbMethods.AppendText( "This is a non Static Method and needs an Instance to act upon`n`n" )  
         $rtbMethods.AppendText( "The Example given will use the Key Properties to Connect to a WMI Instance : `n`n" )  
         $rtbMethods.SelectionColor = 'Green'  
         $rtbMethods.SelectionFont = $fontCode  
         $rtbMethods.AppendText("# Example Of Connecting to an Instance`n`n")  
     
         $rtbMethods.SelectionColor = 'Black'  
         $rtbMethods.SelectionFont = $fontCode  
         $SB = new-Object text.stringbuilder  
         $SB = $SB.AppendLine('$Computer = "."')  
         $SB = $SB.Append('$Class = "') ; $SB = $SB.AppendLine("$WmiClassName.`"")    
         $SB = $SB.Append('$Method = "') ; $SB = $SB.AppendLine("$WMIMethod`"")  
         $SB = $SB.AppendLine("`n# $WmiClassName. Key Properties :")    
         $Filter = ""    
         $script:WmiClass.psbase.Properties | ForEach-Object {    
           $Q = @()  
           $_.psbase.Qualifiers | ForEach-Object {$Q += $_.name}   
           $key = $Q -Contains "key"   
           If ($key) {    
             $CIMType = $_.psbase.Qualifiers["Cimtype"].Value    
             $SB = $SB.AppendLine("`$$($_.Name) = [$CIMType]")    
             $Filter += "$($_.name) = `'`$$($_.name)`'"     
           }    
         }    
         $SB = $SB.Append("`n" + '$filter=');$SB = $SB.AppendLine("`"$filter`"")    
         $SB = $SB.AppendLine('$MC = get-WMIObject $class -computer $Computer -Namespace "' +  
             "$($script:WmiClass.__NAMESPACE)" + '" -filter $filter' + "`n")  
         $SB = $SB.AppendLine('# $MC = [Wmi]"\\$Computer\Root\CimV2:$Class.$filter"')   
         $rtbMethods.AppendText(($sb.tostring()))  
    }   
    $SB = $SB.AppendLine('$InParams = $mc.psbase.GetMethodParameters($Method)')  
    $SB = $SB.AppendLine("`n")  
    # output Method Parameter Help  
    $rtbMethods.selectionFont  = $fontBold  
    $rtbMethods.AppendText("`n`n$WmiClassName. $WMIMethod Method :`n`n")   
    $q = $script:WmiClass.PSBase.Methods[$WMIMethod].Qualifiers | foreach {$_.name}  
    if ($q -contains "Description") {  
         $rtbMethods.AppendText(($script:WmiClass.psbase.Methods[$WMIMethod].psbase.Qualifiers["Description"].Value))  
    }   
   
    $rtbMethods.selectionFont  = $fontBold  
    $rtbMethods.AppendText("`n`n$WMIMethod Parameters :`n")   
  # get the Parameters   
    
  $inParam = $script:WmiClass.psbase.GetMethodParameters($WmiMethod)  
  $HasParams = $False   
  if ($true) {   
    trap{$rtbMethods.AppendText('[None]') ;continue}    
    $inParam.PSBase.Properties | foreach {   
      $Q = $_.Qualifiers | foreach {$_.name}  
      # if Optional Qualifier is not present then Parameter is Mandatory   
      $Optional = $q -contains "Optional"  
      $CIMType = $_.Qualifiers["Cimtype"].Value   
      $rtbMethods.AppendText("`nName = $($_.Name) `nType = $CIMType `nOptional = $Optional")  
      # write Parameters to Example script   
      if ($Optional -eq $TRUE) {$SB = $SB.Append('# ')}   
      $SB = $SB.Append('$InParams.');$SB = $SB.Append("$($_.Name) = ");$SB = $SB.AppendLine("[$CIMType]")   
      if ($q -contains "Description") {$rtbMethods.AppendText($_.Qualifiers["Description"].Value)}  
      $HasParams = $true    
    }   
  }  
  # Create the Rest of the Script  
  $rtbMethods.selectionFont  = $fontBold  
  $rtbMethods.AppendText("`n`nTemplate Script :`n")   
  # Call diferent Overload as Method has No Parameters   
  If ($HasParams -eq $True) {   
      $SB = $SB.AppendLine("`n`"Calling $WmiClassName. : $WMIMethod with Parameters :`"")   
      $SB = $SB.AppendLine('$inparams.PSBase.properties | select name,Value | format-Table')   
      $SB = $SB.AppendLine("`n" + '$R = $mc.PSBase.InvokeMethod($Method, $inParams, $Null)')   
  }Else{   
      $SB = $SB.AppendLine("`n`"Calling $WmiClassName. : $WMIMethod `"")   
      $SB = $SB.AppendLine("`n" + '$R = $mc.PSBase.InvokeMethod($Method,$Null)')   
  }   
  $SB = $SB.AppendLine('"Result :"')   
  $SB = $SB.AppendLine('$R | Format-list' + "`n`n")  
  # Write Header of the Sample Script :   
   
  $rtbMethods.SelectionColor = 'Green'  
  $rtbMethods.SelectionFont = $fontCode  
  $rtbMethods.AppendText(@"  
# $WmiClassName. $WMIMethod-Method Template Script"   
# Created by PowerShell WmiExplorer  
# /\/\o\/\/ 2006  
# www.ThePowerShellGuy.com  
#  
# Fill InParams values before Executing   
# InParams that are Remarked (#) are Optional  
"@  
  )  
  $rtbMethods.SelectionColor = 'Black'  
  #$rtbMethods.SelectionFont = $fontCode  
  $rtbMethods.AppendText("`n`n" + $SB)  
  $rtbMethods.SelectionFont = new-object System.Drawing.Font("Lucida Console",6 )  
  $rtbMethods.AppendText("`n`n Generated by the PowerShell WMI Explorer  /\/\o\/\/ 2006" )  
         
} # GetWmiMethod  
#endregion  
#endregion  
# Show the Form  
$FrmMain.Add_Shown({$FrmMain.Activate()})  
   
trap {Write-Host $_ ;$status.Text = "unexpected error";$slMessage.Text = "$_.message";continue}  
& {  
    [void]$FrmMain.showdialog()  
}  
# Resolve-Error $Error[0] | out-string 