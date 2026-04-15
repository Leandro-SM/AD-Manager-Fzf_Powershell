Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===Instalar Módulo do AD===
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Host "Erro: Módulo ActiveDirectory não encontrado. Instale RSAT Tools pelos recusros do Windows." -ForegroundColor Red
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey()
    exit
}

$script:CurrentMenu = "main"
$script:SelectedIndex = 0
$script:SearchResults = @()
$script:GroupResults = @()
$script:CurrentPage = 0
$script:PageSize = 10
$script:TasksPath = "$env:USERPROFILE\ADManager_Tasks.json"

# ===Cores===
$script:Colors = @{
    Header = [ConsoleColor]::Cyan
    Selected = [ConsoleColor]::Green
    Normal = [ConsoleColor]::White
    Error = [ConsoleColor]::Red
    Info = [ConsoleColor]::Yellow
    Border = [ConsoleColor]::DarkGray
    Warning = [ConsoleColor]::Magenta
    Success = [ConsoleColor]::Green
}

# ===Cabecalho===
function Clear-Screen {
    Clear-Host
    Write-Host ("=" * 80) -ForegroundColor $script:Colors.Error
    Write-Host "                     AD Manager - Fzf" -ForegroundColor $script:Colors.Warning
    Write-Host ("=" * 80) -ForegroundColor $script:Colors.Normal
    Write-Host ""
}

function Show-MainMenu {
    Clear-Screen
    
    $menuItems = @(
        "👥  Gerenciar Usuários",
        "📁  Gerenciar Grupos",
        "⏰  Tarefas Agendadas",
        "📊  Relatórios Rápidos",
        "🔧  Utilitários AD",
        "🚪  Sair"
    )
    
    Write-Host "MENU PRINCIPAL" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓  - Navegar    Enter - Selecionar" -ForegroundColor $script:Colors.Info
    Write-Host "q    - Sair       h    - Ajuda" -ForegroundColor $script:Colors.Info
}

function Show-UserMenu {
    Clear-Screen
    
    $menuItems = @(
        "🔍  Buscar usuário",
        "📋  Listar todos usuários (paginado)",
        "➕  Criar novo usuário",
        "✏️  Editar usuário",
        "🔒  Resetar senha",
        "✅  Habilitar/Desabilitar conta",
        "📧  Enviar email para usuário",
        "⬅️  Voltar"
    )
    
    Write-Host "GERENCIAR USUÁRIOS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓/Enter - Navegar    ← - Voltar" -ForegroundColor $script:Colors.Info
}

function Show-GroupMenu {
    Clear-Screen
    
    $menuItems = @(
        "🔍  Buscar grupo",
        "📋  Listar todos grupos",
        "👥  Ver membros do grupo",
        "➕  Adicionar usuário ao grupo",
        "➖  Remover usuário do grupo",
        "📧  Exportar membros para email",
        "📄  Exportar membros para CSV",
        "⬅️  Voltar"
    )
    
    Write-Host "GERENCIAR GRUPOS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓/Enter - Navegar    ← - Voltar" -ForegroundColor $script:Colors.Info
}

function Show-TaskMenu {
    Clear-Screen
    
    $menuItems = @(
        "📅  Criar nova tarefa agendada",
        "📋  Listar tarefas existentes",
        "✏️  Editar tarefa",
        "🗑️  Remover tarefa",
        "▶️  Executar tarefa agora",
        "⬅️  Voltar"
    )
    
    Write-Host "TAREFAS AGENDADAS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓/Enter - Navegar    ← - Voltar" -ForegroundColor $script:Colors.Info
}

function Show-ReportsMenu {
    Clear-Screen
    
    $menuItems = @(
        "📈  Usuários por departamento",
        "🔐  Usuários com senha expirada",
        "⏸️  Usuários inativos (90 dias)",
        "👤  Usuários sem manager",
        "📧  Usuários sem email",
        "⬅️  Voltar"
    )
    
    Write-Host "RELATÓRIOS RÁPIDOS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓/Enter - Navegar    ← - Voltar" -ForegroundColor $script:Colors.Info
}

function Show-UtilitiesMenu {
    Clear-Screen
    
    $menuItems = @(
        "🔍  Testar conexão AD",
        "📊  Estatísticas do domínio",
        "🔄  Sincronizar com Exchange (se disponível)",
        "📝  Gerar relatório completo em HTML",
        "⬅️  Voltar"
    )
    
    Write-Host "UTILITÁRIOS AD" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → $($menuItems[$i])" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor $script:Colors.Normal
        }
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓/Enter - Navegar    ← - Voltar" -ForegroundColor $script:Colors.Info
}

function Show-Help {
    Clear-Screen
    Write-Host "AJUDA DO AD MANAGER CLI" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Comandos de navegação:" -ForegroundColor Yellow
    Write-Host "  ↑/↓     - Navegar entre opções"
    Write-Host "  Enter   - Selecionar opção"
    Write-Host "  ←       - Voltar para menu anterior"
    Write-Host "  q       - Sair do programa"
    Write-Host "  h       - Mostrar esta ajuda"
    Write-Host ""
    Write-Host "Funcionalidades disponíveis:" -ForegroundColor Yellow
    Write-Host "  • Busca interativa de usuários e grupos"
    Write-Host "  • Visualização detalhada de informações"
    Write-Host "  • Gerenciamento de grupos e membros"
    Write-Host "  • Criação de tarefas agendadas"
    Write-Host "  • Exportação de relatórios por email"
    Write-Host "  • Reset de senha e gerenciamento de contas"
    Write-Host ""
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}


function Search-Users {
    Clear-Screen
    
    Write-Host "BUSCAR USUÁRIOS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    Write-Host "Digite o nome, login ou email (ou 'sair' para voltar):" -ForegroundColor $script:Colors.Info
    Write-Host ""
    
    $searchTerm = Read-Host "🔍 Buscar"
    
    if ($searchTerm -eq "sair" -or $searchTerm -eq "") {
        return
    }
    
    Write-Host "`nBuscando..." -ForegroundColor $script:Colors.Info
    
    $script:SearchResults = Get-ADUser -Filter "DisplayName -like '*$searchTerm*' -or SamAccountName -like '*$searchTerm*' -or Mail -like '*$searchTerm*'" -Properties DisplayName, SamAccountName, Mail, Department, Title, Enabled |
        Select-Object DisplayName, SamAccountName, Mail, Department, Title, Enabled
    
    if ($script:SearchResults.Count -eq 0) {
        Write-Host "`nNenhum usuário encontrado!" -ForegroundColor $script:Colors.Error
        Write-Host "`nPressione qualquer tecla para tentar novamente..."
        $null = $Host.UI.RawUI.ReadKey()
        Search-Users
        return
    }
    
    $script:SelectedIndex = 0
    $script:CurrentPage = 0
    Show-UserResults
}

function Show-UserResults {
    Clear-Screen
    
    $totalPages = [Math]::Ceiling($script:SearchResults.Count / $script:PageSize)
    $startIndex = $script:CurrentPage * $script:PageSize
    $endIndex = [Math]::Min($startIndex + $script:PageSize, $script:SearchResults.Count)
    
    Write-Host "RESULTADOS DA BUSCA ($($script:SearchResults.Count) usuários)" -ForegroundColor $script:Colors.Header
    Write-Host "Página $($script:CurrentPage + 1)/$totalPages" -ForegroundColor $script:Colors.Info
    Write-Host ""
    
    $displayIndex = 0
    for ($i = $startIndex; $i -lt $endIndex; $i++) {
        $user = $script:SearchResults[$i]
        $status = if ($user.Enabled) { "✓" } else { "✗" }
        
        if ($displayIndex -eq $script:SelectedIndex) {
            Write-Host " → $status $($user.DisplayName)" -NoNewline -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
            Write-Host " ($($user.SamAccountName))" -NoNewline -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
            Write-Host " - $($user.Mail)" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $status $($user.DisplayName)" -NoNewline
            Write-Host " ($($user.SamAccountName))" -NoNewline -ForegroundColor Gray
            Write-Host " - $($user.Mail)" -ForegroundColor Gray
        }
        
        if ($user.Department) {
            Write-Host "      📁 $($user.Department) | 🏷️  $($user.Title)" -ForegroundColor DarkGray
        }
        $displayIndex++
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓ - Navegar    ←/→ - Páginas" -ForegroundColor $script:Colors.Info
    Write-Host "Enter - Ver detalhes    n - Nova busca" -ForegroundColor $script:Colors.Info
    Write-Host "q - Voltar ao menu" -ForegroundColor $script:Colors.Info
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        38 { # Up
            if ($script:SelectedIndex -gt 0) {
                $script:SelectedIndex--
            } else {
                if ($script:CurrentPage -gt 0) {
                    $script:CurrentPage--
                    $script:SelectedIndex = $script:PageSize - 1
                }
            }
            Show-UserResults
        }
        40 { # Down
            $maxItems = [Math]::Min($script:PageSize, $script:SearchResults.Count - ($script:CurrentPage * $script:PageSize))
            if ($script:SelectedIndex -lt $maxItems - 1) {
                $script:SelectedIndex++
            } else {
                if ($script:CurrentPage -lt $totalPages - 1) {
                    $script:CurrentPage++
                    $script:SelectedIndex = 0
                }
            }
            Show-UserResults
        }
        37 { # Left
            if ($script:CurrentPage -gt 0) {
                $script:CurrentPage--
                $script:SelectedIndex = 0
            }
            Show-UserResults
        }
        39 { # Right
            if ($script:CurrentPage -lt $totalPages - 1) {
                $script:CurrentPage++
                $script:SelectedIndex = 0
            }
            Show-UserResults
        }
        13 { # Enter
            $index = $script:CurrentPage * $script:PageSize + $script:SelectedIndex
            $selectedUser = $script:SearchResults[$index]
            Show-UserDetails $selectedUser
        }
        78 { # N
            Search-Users
        }
        81 { # Q
            return
        }
    }
}

function Show-UserDetails {
    param($User)
    
    Clear-Screen
    
    Write-Host "DETALHES DO USUÁRIO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    # Buscar informações completas
    $fullUser = Get-ADUser -Identity $User.SamAccountName -Properties *
    
    Write-Host "📋 INFORMAÇÕES BÁSICAS" -ForegroundColor $script:Colors.Info
    Write-Host "   Nome completo: $($fullUser.DisplayName)"
    Write-Host "   Nome de usuário: $($fullUser.SamAccountName)"
    Write-Host "   Email: $($fullUser.Mail)"
    Write-Host "   UPN: $($fullUser.UserPrincipalName)"
    Write-Host "   Status: $(if ($fullUser.Enabled) { 'Ativo' } else { 'Inativo' })" -ForegroundColor $(if ($fullUser.Enabled) { 'Green' } else { 'Red' })
    Write-Host ""
    
    Write-Host "🏢 ORGANIZAÇÃO" -ForegroundColor $script:Colors.Info
    Write-Host "   Departamento: $($fullUser.Department)"
    Write-Host "   Cargo: $($fullUser.Title)"
    Write-Host "   Empresa: $($fullUser.Company)"
    Write-Host "   Escritório: $($fullUser.Office)"
    Write-Host "   Gerente: $($fullUser.Manager)"
    Write-Host ""
    
    Write-Host "📞 CONTATO" -ForegroundColor $script:Colors.Info
    Write-Host "   Telefone: $($fullUser.TelephoneNumber)"
    Write-Host "   Celular: $($fullUser.MobilePhone)"
    Write-Host "   Fax: $($fullUser.Fax)"
    Write-Host "   Endereço: $($fullUser.StreetAddress)"
    Write-Host "   Cidade: $($fullUser.City)"
    Write-Host ""
    
    Write-Host "🔐 INFORMAÇÕES DE CONTA" -ForegroundColor $script:Colors.Info
    Write-Host "   Criado em: $($fullUser.Created)"
    Write-Host "   Modificado: $($fullUser.Modified)"
    Write-Host "   Último login: $($fullUser.LastLogonDate)"
    Write-Host "   Última troca de senha: $($fullUser.PasswordLastSet)"
    Write-Host "   Senha expira em: $($fullUser.AccountExpirationDate)"
    Write-Host ""
    
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "← - Voltar    e - Editar    r - Resetar senha" -ForegroundColor $script:Colors.Info
    Write-Host "t - Habilitar/Desabilitar    g - Grupos do usuário" -ForegroundColor $script:Colors.Info
    Write-Host "m - Enviar email" -ForegroundColor $script:Colors.Info
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        37 { Show-UserResults } # Left
        69 { Edit-User $fullUser } # E
        82 { Reset-UserPassword $fullUser } # R
        84 { Toggle-UserStatus $fullUser } # T
        71 { Show-UserGroups $fullUser } # G
        77 { Send-EmailToUser $fullUser } # M
    }
}

function Show-AllUsers {
    Clear-Screen
    
    Write-Host "LISTANDO TODOS OS USUÁRIOS..." -ForegroundColor $script:Colors.Info
    
    $script:SearchResults = Get-ADUser -Filter * -Properties DisplayName, SamAccountName, Mail, Department, Title, Enabled |
        Select-Object DisplayName, SamAccountName, Mail, Department, Title, Enabled |
        Sort-Object DisplayName
    
    $script:SelectedIndex = 0
    $script:CurrentPage = 0
    Show-UserResults
}

function Create-NewUser {
    Clear-Screen
    
    Write-Host "CRIAR NOVO USUÁRIO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $firstName = Read-Host "Primeiro nome"
    $lastName = Read-Host "Sobrenome"
    $samAccountName = Read-Host "Nome de usuário (login)"
    $userPrincipalName = "$samAccountName@$((Get-ADDomain).DNSRoot)"
    $displayName = "$firstName $lastName"
    
    Write-Host "`nDigite a senha inicial:" -ForegroundColor $script:Colors.Info
    $password = Read-Host -AsSecureString
    
    Write-Host "`nCriando usuário..." -ForegroundColor $script:Colors.Info
    
    try {
        New-ADUser -Name $displayName -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -DisplayName $displayName -AccountPassword $password -Enabled $true -PassThru | Out-Null
        Write-Host "✓ Usuário $displayName criado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Edit-User {
    param($User)
    
    Clear-Screen
    
    Write-Host "EDITAR USUÁRIO: $($User.DisplayName)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    Write-Host "Deixe em branco para manter o valor atual"
    Write-Host ""
    
    $newDepartment = Read-Host "Departamento [$($User.Department)]"
    $newTitle = Read-Host "Cargo [$($User.Title)]"
    $newPhone = Read-Host "Telefone [$($User.TelephoneNumber)]"
    $newOffice = Read-Host "Escritório [$($User.Office)]"
    
    try {
        if ($newDepartment) { Set-ADUser -Identity $User.SamAccountName -Department $newDepartment }
        if ($newTitle) { Set-ADUser -Identity $User.SamAccountName -Title $newTitle }
        if ($newPhone) { Set-ADUser -Identity $User.SamAccountName -OfficePhone $newPhone }
        if ($newOffice) { Set-ADUser -Identity $User.SamAccountName -Office $newOffice }
        
        Write-Host "`n✓ Usuário atualizado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "`n✗ Erro ao atualizar: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
    
    # Recarregar usuário atualizado
    $updatedUser = Get-ADUser -Identity $User.SamAccountName -Properties *
    Show-UserDetails $updatedUser
}

function Reset-UserPassword {
    param($User)
    
    Clear-Screen
    
    Write-Host "RESETAR SENHA: $($User.DisplayName)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    Write-Host "Digite a nova senha:" -ForegroundColor $script:Colors.Info
    $newPassword = Read-Host -AsSecureString
    Write-Host "Confirme a nova senha:" -ForegroundColor $script:Colors.Info
    $confirm = Read-Host -AsSecureString
    
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
    
    if ($plain1 -ne $plain2) {
        Write-Host "`n✗ As senhas não coincidem!" -ForegroundColor Red
        Write-Host "`nPressione qualquer tecla para continuar..."
        $null = $Host.UI.RawUI.ReadKey()
        Show-UserDetails $User
        return
    }
    
    try {
        Set-ADAccountPassword -Identity $User.SamAccountName -NewPassword $newPassword -Reset
        Set-ADUser -Identity $User.SamAccountName -ChangePasswordAtLogon $true
        Write-Host "`n✓ Senha resetada com sucesso! Usuário deverá trocar no próximo login." -ForegroundColor Green
    } catch {
        Write-Host "`n✗ Erro ao resetar senha: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
    Show-UserDetails $User
}

function Toggle-UserStatus {
    param($User)
    
    Clear-Screen
    
    $currentStatus = if ($User.Enabled) { "ATIVO" } else { "INATIVO" }
    Write-Host "STATUS ATUAL: $currentStatus" -ForegroundColor $(if ($User.Enabled) { 'Green' } else { 'Red' })
    Write-Host ""
    
    $action = if ($User.Enabled) { "desabilitar" } else { "habilitar" }
    Write-Host "Deseja $action este usuário? (s/n)" -ForegroundColor $script:Colors.Warning
    
    $confirm = Read-Host
    if ($confirm -eq 's') {
        try {
            if ($User.Enabled) {
                Disable-ADAccount -Identity $User.SamAccountName
                Write-Host "`n✓ Usuário desabilitado com sucesso!" -ForegroundColor Green
            } else {
                Enable-ADAccount -Identity $User.SamAccountName
                Write-Host "`n✓ Usuário habilitado com sucesso!" -ForegroundColor Green
            }
        } catch {
            Write-Host "`n✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
    
    $updatedUser = Get-ADUser -Identity $User.SamAccountName -Properties DisplayName, SamAccountName, Mail, Department, Title, Enabled
    Show-UserDetails $updatedUser
}

function Show-UserGroups {
    param($User)
    
    Clear-Screen
    
    Write-Host "GRUPOS DO USUÁRIO: $($User.DisplayName)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $groups = Get-ADPrincipalGroupMembership -Identity $User.SamAccountName | Select-Object Name, GroupCategory, GroupScope | Sort-Object Name
    
    if ($groups.Count -eq 0) {
        Write-Host "Usuário não pertence a nenhum grupo." -ForegroundColor $script:Colors.Warning
    } else {
        foreach ($group in $groups) {
            Write-Host "   • $($group.Name)" -NoNewline
            Write-Host " ($($group.GroupCategory)/$($group.GroupScope))" -ForegroundColor Gray
        }
        Write-Host "`nTotal: $($groups.Count) grupos" -ForegroundColor $script:Colors.Info
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para voltar..."
    $null = $Host.UI.RawUI.ReadKey()
    Show-UserDetails $User
}

function Send-EmailToUser {
    param($User)
    
    Clear-Screen
    
    Write-Host "ENVIAR EMAIL PARA: $($User.DisplayName)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    if (!$User.Mail) {
        Write-Host "✗ Usuário não possui email configurado!" -ForegroundColor Red
        Write-Host "`nPressione qualquer tecla para continuar..."
        $null = $Host.UI.RawUI.ReadKey()
        Show-UserDetails $User
        return
    }
    
    Write-Host "Destinatário: $($User.Mail)" -ForegroundColor Green
    $subject = Read-Host "Assunto"
    Write-Host "Mensagem:" -ForegroundColor $script:Colors.Info
    $body = Read-Host
    
    Write-Host "`nConfigurar servidor SMTP (ou pressione Enter para pular):" -ForegroundColor $script:Colors.Info
    $smtpServer = Read-Host "SMTP Server [smtp.empresa.com]"
    
    if ($smtpServer) {
        try {
            Send-MailMessage -To $User.Mail -From "admanager@$((Get-ADDomain).DNSRoot)" -Subject $subject -Body $body -SmtpServer $smtpServer
            Write-Host "`n✓ Email enviado com sucesso!" -ForegroundColor Green
        } catch {
            Write-Host "`n✗ Erro ao enviar: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "`nEnvio ignorado (SMTP não configurado)" -ForegroundColor Yellow
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
    Show-UserDetails $User
}


function Search-Groups {
    Clear-Screen
    
    Write-Host "BUSCAR GRUPOS" -ForegroundColor $script:Colors.Header
    Write-Host ""
    Write-Host "Digite o nome do grupo (ou 'sair' para voltar):" -ForegroundColor $script:Colors.Info
    Write-Host ""
    
    $searchTerm = Read-Host "🔍 Buscar"
    
    if ($searchTerm -eq "sair" -or $searchTerm -eq "") {
        return
    }
    
    Write-Host "`nBuscando..." -ForegroundColor $script:Colors.Info
    
    $script:GroupResults = Get-ADGroup -Filter "Name -like '*$searchTerm*'" -Properties Description, GroupCategory, GroupScope, GroupType |
        Select-Object Name, SamAccountName, Description, GroupCategory, GroupScope
    
    if ($script:GroupResults.Count -eq 0) {
        Write-Host "`nNenhum grupo encontrado!" -ForegroundColor $script:Colors.Error
        Write-Host "`nPressione qualquer tecla para tentar novamente..."
        $null = $Host.UI.RawUI.ReadKey()
        Search-Groups
        return
    }
    
    $script:SelectedIndex = 0
    Show-GroupResults
}

function Show-GroupResults {
    Clear-Screen
    
    Write-Host "RESULTADOS DA BUSCA ($($script:GroupResults.Count) grupos)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    for ($i = 0; $i -lt $script:GroupResults.Count; $i++) {
        $group = $script:GroupResults[$i]
        
        if ($i -eq $script:SelectedIndex) {
            Write-Host " → " -NoNewline -ForegroundColor $script:Colors.Selected
            Write-Host "$($group.Name)" -NoNewline -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
            Write-Host " ($($group.SamAccountName))" -ForegroundColor $script:Colors.Selected -BackgroundColor DarkGray
        } else {
            Write-Host "   $($group.Name)" -NoNewline
            Write-Host " ($($group.SamAccountName))" -ForegroundColor Gray
        }
        
        if ($group.Description) {
            Write-Host "      📝 $($group.Description)" -ForegroundColor DarkGray
        }
        Write-Host "      🏷️  $($group.GroupCategory)/$($group.GroupScope)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "↑/↓ - Navegar    Enter - Gerenciar grupo" -ForegroundColor $script:Colors.Info
    Write-Host "n   - Nova busca    q - Voltar" -ForegroundColor $script:Colors.Info
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        38 { # Up
            if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- }
            Show-GroupResults
        }
        40 { # Down
            if ($script:SelectedIndex -lt $script:GroupResults.Count - 1) { $script:SelectedIndex++ }
            Show-GroupResults
        }
        13 { # Enter
            $selectedGroup = $script:GroupResults[$script:SelectedIndex]
            Show-GroupMembers $selectedGroup
        }
        78 { # N
            Search-Groups
        }
        81 { # Q
            return
        }
    }
}

function Show-AllGroups {
    Clear-Screen
    
    Write-Host "LISTANDO TODOS OS GRUPOS..." -ForegroundColor $script:Colors.Info
    
    $script:GroupResults = Get-ADGroup -Filter * -Properties Description, GroupCategory, GroupScope |
        Select-Object Name, SamAccountName, Description, GroupCategory, GroupScope |
        Sort-Object Name
    
    $script:SelectedIndex = 0
    Show-GroupResults
}

function Show-GroupMembers {
    param($Group)
    
    Clear-Screen
    
    Write-Host "MEMBROS DO GRUPO: $($Group.Name)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    Write-Host "Carregando membros..." -ForegroundColor $script:Colors.Info
    
    $members = Get-ADGroupMember -Identity $Group.SamAccountName | 
        Where-Object {$_.objectClass -eq "user"} |
        Get-ADUser -Properties DisplayName, Mail, Department, Title
    
    if ($members.Count -eq 0) {
        Write-Host "Nenhum membro encontrado neste grupo." -ForegroundColor $script:Colors.Error
        Write-Host "`nPressione qualquer tecla para voltar..."
        $null = $Host.UI.RawUI.ReadKey()
        Show-GroupResults
        return
    }
    
    $currentPage = 0
    $pageSize = 15
    $totalPages = [Math]::Ceiling($members.Count / $pageSize)
    
    do {
        $startIndex = $currentPage * $pageSize
        $endIndex = [Math]::Min($startIndex + $pageSize, $members.Count)
        
        Clear-Screen
        Write-Host "MEMBROS DO GRUPO: $($Group.Name)" -ForegroundColor $script:Colors.Header
        Write-Host ""
        Write-Host "Total: $($members.Count) membros | Página $($currentPage + 1)/$totalPages" -ForegroundColor $script:Colors.Info
        Write-Host ""
        
        for ($i = $startIndex; $i -lt $endIndex; $i++) {
            $member = $members[$i]
            Write-Host "   $($member.DisplayName)" -NoNewline
            Write-Host " ($($member.SamAccountName))" -ForegroundColor Gray
            if ($member.Department) {
                Write-Host "      📁 $($member.Department)" -ForegroundColor DarkGray
            }
            if ($member.Title) {
                Write-Host "      🏷️  $($member.Title)" -ForegroundColor DarkGray
            }
            if ($member.Mail) {
                Write-Host "      📧 $($member.Mail)" -ForegroundColor DarkGray
            }
            Write-Host ""
        }
        
        Write-Host "────────────────────────────────────────" -ForegroundColor $script:Colors.Border
        Write-Host "←/→ - Páginas    e - Exportar para email" -ForegroundColor $script:Colors.Info
        Write-Host "c - Exportar CSV    q - Voltar" -ForegroundColor $script:Colors.Info
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            37 { # Left
                if ($currentPage -gt 0) { $currentPage-- }
            }
            39 { # Right
                if ($currentPage -lt $totalPages - 1) { $currentPage++ }
            }
            69 { # E
                Export-GroupMembersToEmail -Group $Group -Members $members
                Write-Host "`nRelatório enviado! Pressione qualquer tecla..." -ForegroundColor Green
                $null = $Host.UI.RawUI.ReadKey()
            }
            67 { # C
                Export-GroupMembersToCSV -Group $Group -Members $members
                Write-Host "`nCSV exportado! Pressione qualquer tecla..." -ForegroundColor Green
                $null = $Host.UI.RawUI.ReadKey()
            }
            81 { # Q
                Show-GroupResults
                return
            }
        }
    } while ($true)
}

function Add-UserToGroup {
    Clear-Screen
    
    Write-Host "ADICIONAR USUÁRIO AO GRUPO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    # Buscar usuário
    $userName = Read-Host "Nome de usuário (SamAccountName)"
    $groupName = Read-Host "Nome do grupo"
    
    try {
        Add-ADGroupMember -Identity $groupName -Members $userName
        Write-Host "`n✓ Usuário $userName adicionado ao grupo $groupName com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "`n✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Remove-UserFromGroup {
    Clear-Screen
    
    Write-Host "REMOVER USUÁRIO DO GRUPO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    # Buscar usuário
    $userName = Read-Host "Nome de usuário (SamAccountName)"
    $groupName = Read-Host "Nome do grupo"
    
    try {
        Remove-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false
        Write-Host "`n✓ Usuário $userName removido do grupo $groupName com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "`n✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Export-GroupMembersToEmail {
    param($Group, $Members)
    
    Clear-Screen
    Write-Host "ENVIAR RELATÓRIO POR EMAIL" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $emailTo = Read-Host "Email do destinatário"
    $emailSubject = Read-Host "Assunto (Enter para padrão)"
    
    if ([string]::IsNullOrWhiteSpace($emailSubject)) {
        $emailSubject = "Relatório de membros do grupo: $($Group.Name)"
    }
    
    # Criar relatório HTML
    $html = @"
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; }
            h1 { color: #2c3e50; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #4CAF50; color: white; }
            tr:nth-child(even) { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <h1>Relatório de Membros do Grupo</h1>
        <h2>Grupo: $($Group.Name)</h2>
        <p>Total de membros: $($Members.Count)</p>
        <p>Data de geração: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
        <table>
            <tr>
                <th>Nome</th>
                <th>Login</th>
                <th>Email</th>
                <th>Departamento</th>
            </tr>
"@

    foreach ($member in $Members) {
        $html += @"
            <tr>
                <td>$($member.DisplayName)</td>
                <td>$($member.SamAccountName)</td>
                <td>$($member.Mail)</td>
                <td>$($member.Department)</td>
            </tr>
"@
    }
    
    $html += @"
        </table>
        <hr>
        <p>Relatório gerado automaticamente pelo AD Manager CLI</p>
    </body>
    </html>
"@
    
    # Enviar email
    $smtpServer = Read-Host "SMTP Server (ex: smtp.empresa.com)"
    $smtpPort = Read-Host "Porta [587]"
    if ([string]::IsNullOrWhiteSpace($smtpPort)) { $smtpPort = 587 }
    $from = Read-Host "Email remetente [admanager@dominio.com]"
    
    try {
        Send-MailMessage -To $emailTo -From $from -Subject $emailSubject -Body $html -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort
        Write-Host "✓ Email enviado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erro ao enviar email: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Configure as configurações SMTP corretamente." -ForegroundColor Yellow
    }
}

function Export-GroupMembersToCSV {
    param($Group, $Members)
    
    $csvPath = "$env:USERPROFILE\Downloads\grupo_$($Group.SamAccountName)_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    
    $exportData = @()
    foreach ($member in $Members) {
        $exportData += [PSCustomObject]@{
            Nome = $member.DisplayName
            Login = $member.SamAccountName
            Email = $member.Mail
            Departamento = $member.Department
            Cargo = $member.Title
        }
    }
    
    $exportData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "✓ CSV exportado com sucesso para: $csvPath" -ForegroundColor Green
}


function Load-Tasks {
    if (Test-Path $script:TasksPath) {
        $tasks = Get-Content $script:TasksPath | ConvertFrom-Json
        return $tasks
    }
    return @()
}

function Save-Tasks($tasks) {
    $tasks | ConvertTo-Json -Depth 10 | Set-Content $script:TasksPath
}

function Create-ScheduledTask {
    Clear-Screen
    
    Write-Host "CRIAR NOVA TAREFA AGENDADA" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $taskName = Read-Host "Nome da tarefa"
    $groupName = Read-Host "Nome do grupo AD"
    $emailTo = Read-Host "Email para enviar relatório"
    $schedule = Read-Host "Frequência (daily/weekly/monthly)"
    $time = Read-Host "Horário (HH:MM)"
    
    $scriptContent = @"
# Tarefa: $taskName
# Grupo: $groupName
# Gerado em: $(Get-Date)

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

try {
    `$group = Get-ADGroup "$groupName" -ErrorAction Stop
    `$members = Get-ADGroupMember -Identity `$group.SamAccountName | Where-Object {`$_.objectClass -eq "user"} | Get-ADUser -Properties DisplayName, Mail, Department, Title
    
    # Criar relatório em texto
    `$report = "=" * 60 + "`r`n"
    `$report += "RELATORIO DE MEMBROS DO GRUPO`r`n"
    `$report += "=" * 60 + "`r`n"
    `$report += "Grupo: `$(`$group.Name)`r`n"
    `$report += "Data: `$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`r`n"
    `$report += "Total de membros: `$(`$members.Count)`r`n"
    `$report += "=" * 60 + "`r`n`r`n"
    
    foreach (`$member in `$members) {
        `$report += "Nome: `$(`$member.DisplayName)`r`n"
        `$report += "Login: `$(`$member.SamAccountName)`r`n"
        `$report += "Email: `$(`$member.Mail)`r`n"
        `$report += "Departamento: `$(`$member.Department)`r`n"
        `$report += "Cargo: `$(`$member.Title)`r`n"
        `$report += "-" * 40 + "`r`n"
    }
    
    # Salvar relatório local
    `$reportPath = "`$env:TEMP\relatorio_`$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    `$report | Out-File -FilePath `$reportPath -Encoding UTF8
    
    # Tentar enviar email se SMTP estiver configurado
    try {
        Send-MailMessage -To "$emailTo" -From "admanager@`$((Get-ADDomain).DNSRoot)" -Subject "Relatorio Automatico: `$(`$group.Name)" -Body `$report -SmtpServer "smtp.empresa.com" -Port 587 -ErrorAction SilentlyContinue
    } catch {
        # Email falhou, apenas continua
    }
    
    # Log
    `$logEntry = "`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Relatorio gerado para grupo: `$(`$group.Name) - Total: `$(`$members.Count) membros"
    Add-Content -Path "`$env:TEMP\ADManager_Task.log" -Value `$logEntry
}
catch {
    `$errorLog = "`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERRO: `$(`$_.Exception.Message)"
    Add-Content -Path "`$env:TEMP\ADManager_Task.log" -Value `$errorLog
}
"@
    
    $scriptPath = "$env:TEMP\task_$($taskName -replace ' ', '_').ps1"
    $scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8
    
    try {
        $trigger = switch ($schedule.ToLower()) {
            "daily" { New-ScheduledTaskTrigger -Daily -At $time }
            "weekly" { New-ScheduledTaskTrigger -Weekly -At $time }
            "monthly" { New-ScheduledTaskTrigger -Monthly -At $time }
            default { New-ScheduledTaskTrigger -Daily -At $time }
        }
        
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        Register-ScheduledTask -TaskName "ADManager_$taskName" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
        
        # Salvar nos tasks locais
        $tasks = Load-Tasks
        $tasks += [PSCustomObject]@{
            Name = $taskName
            GroupName = $groupName
            EmailTo = $emailTo
            Schedule = $schedule
            Time = $time
            ScriptPath = $scriptPath
            Created = Get-Date
        }
        Save-Tasks $tasks
        
        Write-Host "`n✓ Tarefa '$taskName' criada com sucesso!" -ForegroundColor Green
        Write-Host "  Script: $scriptPath"
        Write-Host "  Agendamento: $schedule às $time"
        Write-Host "  Tarefa registrada no Windows Task Scheduler como: ADManager_$taskName"
    } catch {
        Write-Host "`n✗ Erro ao criar tarefa: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Remove-Task {
    Clear-Screen
    
    Write-Host "REMOVER TAREFA" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $tasks = Load-Tasks
    
    if ($tasks.Count -eq 0) {
        Write-Host "Nenhuma tarefa agendada encontrada." -ForegroundColor $script:Colors.Warning
        Write-Host "`nPressione qualquer tecla para continuar..."
        $null = $Host.UI.RawUI.ReadKey()
        return
    }
    
    Write-Host "Tarefas disponíveis:" -ForegroundColor $script:Colors.Info
    for ($i = 0; $i -lt $tasks.Count; $i++) {
        Write-Host "$($i+1). $($tasks[$i].Name) - $($tasks[$i].Schedule)"
    }
    
    Write-Host ""
    $choice = Read-Host "Selecione o numero da tarefa para remover (0 para cancelar)"
    
    if ($choice -gt 0 -and $choice -le $tasks.Count) {
        $taskToRemove = $tasks[$choice - 1]
        
        # Remover do Task Scheduler
        try {
            Unregister-ScheduledTask -TaskName "ADManager_$($taskToRemove.Name)" -Confirm:$false -ErrorAction SilentlyContinue
        } catch {
            # Ignorar erro se a tarefa não existir
        }
        
        # Remover do arquivo
        $newTasks = $tasks | Where-Object {$_.Name -ne $taskToRemove.Name}
        Save-Tasks $newTasks
        
        # Remover script
        if (Test-Path $taskToRemove.ScriptPath) {
            Remove-Item $taskToRemove.ScriptPath -Force
        }
        
        Write-Host "`n✓ Tarefa '$($taskToRemove.Name)' removida com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`nOperacao cancelada." -ForegroundColor Yellow
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Execute-TaskNow {
    Clear-Screen
    
    Write-Host "EXECUTAR TAREFA AGORA" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $tasks = Load-Tasks
    
    if ($tasks.Count -eq 0) {
        Write-Host "Nenhuma tarefa agendada encontrada." -ForegroundColor $script:Colors.Warning
        Write-Host "`nPressione qualquer tecla para continuar..."
        $null = $Host.UI.RawUI.ReadKey()
        return
    }
    
    Write-Host "Tarefas disponíveis:" -ForegroundColor $script:Colors.Info
    for ($i = 0; $i -lt $tasks.Count; $i++) {
        Write-Host "$($i+1). $($tasks[$i].Name) - Grupo: $($tasks[$i].GroupName)"
    }
    
    Write-Host ""
    $choice = Read-Host "Selecione o número da tarefa para executar (0 para cancelar)"
    
    if ($choice -gt 0 -and $choice -le $tasks.Count) {
        $task = $tasks[$choice - 1]
        
        Write-Host "`nExecutando tarefa '$($task.Name)'..." -ForegroundColor $script:Colors.Info
        
        try {
            & $task.ScriptPath
            Write-Host "✓ Tarefa executada com sucesso!" -ForegroundColor Green
        } catch {
            Write-Host "✗ Erro ao executar tarefa: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "`nOperação cancelada." -ForegroundColor Yellow
    }
    
    Write-Host "`nPressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}


# ===RELATÓRIOS===

function Report-UsersByDepartment {
    Clear-Screen
    
    Write-Host "USUÁRIOS POR DEPARTAMENTO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $users = Get-ADUser -Filter * -Properties Department
    $groups = $users | Where-Object {$_.Department} | Group-Object Department | Sort-Object Count -Descending
    
    foreach ($group in $groups) {
        Write-Host "📁 $($group.Name): $($group.Count) usuários" -ForegroundColor $script:Colors.Info
    }
    
    Write-Host "`nTotal de usuários: $($users.Count)" -ForegroundColor $script:Colors.Success
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Report-ExpiredPasswords {
    Clear-Screen
    
    Write-Host "USUÁRIOS COM SENHA EXPIRADA" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $expiredUsers = Get-ADUser -Filter {Enabled -eq $true} -Properties PasswordLastSet, PasswordExpired |
        Where-Object {$_.PasswordExpired -eq $true}
    
    if ($expiredUsers.Count -eq 0) {
        Write-Host "Nenhum usuário com senha expirada encontrado." -ForegroundColor Green
    } else {
        foreach ($user in $expiredUsers) {
            Write-Host "   • $($user.Name) ($($user.SamAccountName))" -ForegroundColor Yellow
        }
        Write-Host "`nTotal: $($expiredUsers.Count) usuários" -ForegroundColor $script:Colors.Warning
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Report-InactiveUsers {
    Clear-Screen
    
    Write-Host "USUÁRIOS INATIVOS (90+ DIAS)" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $inactiveDate = (Get-Date).AddDays(-90)
    $inactiveUsers = Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
        Where-Object {$_.LastLogonDate -lt $inactiveDate -or $_.LastLogonDate -eq $null}
    
    if ($inactiveUsers.Count -eq 0) {
        Write-Host "Nenhum usuário inativo encontrado." -ForegroundColor Green
    } else {
        foreach ($user in $inactiveUsers) {
            $lastLogon = if ($user.LastLogonDate) { $user.LastLogonDate.ToString('dd/MM/yyyy') } else { "Nunca logou" }
            Write-Host "   • $($user.Name) ($($user.SamAccountName)) - Último login: $lastLogon" -ForegroundColor Yellow
        }
        Write-Host "`nTotal: $($inactiveUsers.Count) usuários inativos" -ForegroundColor $script:Colors.Warning
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Report-UsersWithoutManager {
    Clear-Screen
    
    Write-Host "USUÁRIOS SEM MANAGER" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $usersWithoutManager = Get-ADUser -Filter * -Properties Manager |
        Where-Object {-not $_.Manager}
    
    if ($usersWithoutManager.Count -eq 0) {
        Write-Host "Todos os usuários possuem manager definido." -ForegroundColor Green
    } else {
        foreach ($user in $usersWithoutManager) {
            Write-Host "   • $($user.Name) ($($user.SamAccountName))" -ForegroundColor Yellow
        }
        Write-Host "`nTotal: $($usersWithoutManager.Count) usuários sem manager" -ForegroundColor $script:Colors.Warning
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Report-UsersWithoutEmail {
    Clear-Screen
    
    Write-Host "USUÁRIOS SEM EMAIL" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $usersWithoutEmail = Get-ADUser -Filter * -Properties Mail |
        Where-Object {-not $_.Mail}
    
    if ($usersWithoutEmail.Count -eq 0) {
        Write-Host "Todos os usuários possuem email configurado." -ForegroundColor Green
    } else {
        foreach ($user in $usersWithoutEmail) {
            Write-Host "   • $($user.Name) ($($user.SamAccountName))" -ForegroundColor Yellow
        }
        Write-Host "`nTotal: $($usersWithoutEmail.Count) usuários sem email" -ForegroundColor $script:Colors.Warning
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}


function Test-ADConnection {
    Clear-Screen
    
    Write-Host "TESTE DE CONEXÃO AD" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    try {
        $domain = Get-ADDomain
        Write-Host "✓ Conexão com AD estabelecida com sucesso!" -ForegroundColor Green
        Write-Host "  Domínio: $($domain.DNSRoot)" -ForegroundColor $script:Colors.Info
        Write-Host "  Controladores disponíveis:" -ForegroundColor $script:Colors.Info
        foreach ($dc in $domain.ReplicaDirectoryServers) {
            Write-Host "    • $dc" -ForegroundColor Gray
        }
    } catch {
        Write-Host "✗ Falha na conexão com AD: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Show-DomainStats {
    Clear-Screen
    
    Write-Host "ESTATÍSTICAS DO DOMÍNIO" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    try {
        $domain = Get-ADDomain
        $users = Get-ADUser -Filter *
        $computers = Get-ADComputer -Filter *
        $groups = Get-ADGroup -Filter *
        
        Write-Host "📊 INFORMAÇÕES GERAIS" -ForegroundColor $script:Colors.Info
        Write-Host "   Domínio: $($domain.DNSRoot)"
        Write-Host "   NetBIOS: $($domain.NetBIOSName)"
        Write-Host "   Nível funcional: $($domain.DomainMode)"
        Write-Host ""
        
        Write-Host "📈 QUANTITATIVOS" -ForegroundColor $script:Colors.Info
        Write-Host "   Total de usuários: $($users.Count)" -ForegroundColor Green
        Write-Host "   Total de computadores: $($computers.Count)" -ForegroundColor Green
        Write-Host "   Total de grupos: $($groups.Count)" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "🖥️ CONTROLADORES" -ForegroundColor $script:Colors.Info
        foreach ($dc in $domain.ReplicaDirectoryServers) {
            Write-Host "   • $dc" -ForegroundColor Gray
        }
    } catch {
        Write-Host "✗ Erro ao obter estatísticas: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}

function Generate-HtmlReport {
    Clear-Screen
    
    Write-Host "GERAR RELATÓRIO COMPLETO HTML" -ForegroundColor $script:Colors.Header
    Write-Host ""
    
    $reportPath = "$env:USERPROFILE\Downloads\AD_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    Write-Host "Gerando relatório, aguarde..." -ForegroundColor $script:Colors.Info
    
    $users = Get-ADUser -Filter * -Properties DisplayName, SamAccountName, Mail, Department, Title, Enabled, LastLogonDate, Created
    $computers = Get-ADComputer -Filter * -Properties Name, OperatingSystem, LastLogonDate
    $groups = Get-ADGroup -Filter * -Properties Name, GroupCategory, GroupScope
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Relatório Completo AD</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; background-color: white; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #3498db; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        tr:hover { background-color: #e8f4f8; }
        .stats { display: inline-block; margin: 10px; padding: 15px; background-color: white; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .stats-number { font-size: 24px; font-weight: bold; color: #3498db; }
        .stats-label { color: #7f8c8d; }
    </style>
</head>
<body>
    <h1>Relatório Completo do Active Directory</h1>
    <p>Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
    
    <div>
        <div class='stats'><div class='stats-number'>$($users.Count)</div><div class='stats-label'>Usuários</div></div>
        <div class='stats'><div class='stats-number'>$($computers.Count)</div><div class='stats-label'>Computadores</div></div>
        <div class='stats'><div class='stats-number'>$($groups.Count)</div><div class='stats-label'>Grupos</div></div>
    </div>
    
    <h2>Usuários</h2>
    <table>
        <tr><th>Nome</th><th>Login</th><th>Email</th><th>Departamento</th><th>Cargo</th><th>Status</th><th>Último Login</th></tr>
"@
    
    foreach ($user in $users | Sort-Object DisplayName) {
        $status = if ($user.Enabled) { "<span style='color:green'>Ativo</span>" } else { "<span style='color:red'>Inativo</span>" }
        $lastLogon = if ($user.LastLogonDate) { $user.LastLogonDate.ToString('dd/MM/yyyy') } else { "Nunca" }
        $html += "<tr><td>$($user.DisplayName)</td><td>$($user.SamAccountName)</td><td>$($user.Mail)</td><td>$($user.Department)</td><td>$($user.Title)</td><td>$status</td><td>$lastLogon</td></tr>"
    }
    
    $html += @"
    </table>
    
    <h2>Computadores</h2>
    <table>
        <tr><th>Nome</th><th>Sistema Operacional</th><th>Último Login</th></tr>
"@
    
    foreach ($computer in $computers | Sort-Object Name) {
        $lastLogon = if ($computer.LastLogonDate) { $computer.LastLogonDate.ToString('dd/MM/yyyy') } else { "Nunca" }
        $html += "<tr><td>$($computer.Name)</td><td>$($computer.OperatingSystem)</td><td>$lastLogon</td></tr>"
    }
    
    $html += @"
    </table>
    
    <h2>Grupos</h2>
    <table>
        <tr><th>Nome</th><th>Categoria</th><th>Escopo</th></tr>
"@
    
    foreach ($group in $groups | Sort-Object Name) {
        $html += "<tr><td>$($group.Name)</td><td>$($group.GroupCategory)</td><td>$($group.GroupScope)</td></tr>"
    }
    
    $html += @"
    </table>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "✓ Relatório gerado com sucesso: $reportPath" -ForegroundColor Green
    
    Write-Host "`n────────────────────────────────────────" -ForegroundColor $script:Colors.Border
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey()
}


function Start-ADManager {
    while ($true) {
        switch ($script:CurrentMenu) {
            "main" {
                Show-MainMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { # Up
                        if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- }
                    }
                    40 { # Down
                        if ($script:SelectedIndex -lt 5) { $script:SelectedIndex++ }
                    }
                    13 { # Enter
                        switch ($script:SelectedIndex) {
                            0 { $script:CurrentMenu = "users"; $script:SelectedIndex = 0 }
                            1 { $script:CurrentMenu = "groups"; $script:SelectedIndex = 0 }
                            2 { $script:CurrentMenu = "tasks"; $script:SelectedIndex = 0 }
                            3 { $script:CurrentMenu = "reports"; $script:SelectedIndex = 0 }
                            4 { $script:CurrentMenu = "utilities"; $script:SelectedIndex = 0 }
                            5 { exit }
                        }
                    }
                    81 { exit } # Q
                    72 { Show-Help } # H
                }
            }
            
            "users" {
                Show-UserMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- } }
                    40 { if ($script:SelectedIndex -lt 7) { $script:SelectedIndex++ } }
                    13 {
                        switch ($script:SelectedIndex) {
                            0 { Search-Users }
                            1 { Show-AllUsers }
                            2 { Create-NewUser }
                            3 { 
                                $user = Read-Host "Digite o SamAccountName do usuário"
                                $userObj = Get-ADUser -Identity $user -Properties *
                                Edit-User $userObj
                            }
                            4 {
                                $user = Read-Host "Digite o SamAccountName do usuário"
                                $userObj = Get-ADUser -Identity $user -Properties *
                                Reset-UserPassword $userObj
                            }
                            5 {
                                $user = Read-Host "Digite o SamAccountName do usuário"
                                $userObj = Get-ADUser -Identity $user -Properties *
                                Toggle-UserStatus $userObj
                            }
                            6 {
                                $user = Read-Host "Digite o SamAccountName do usuário"
                                $userObj = Get-ADUser -Identity $user -Properties Mail, DisplayName
                                Send-EmailToUser $userObj
                            }
                            7 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                        }
                    }
                    37 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 } # Left
                }
            }
            
            "groups" {
                Show-GroupMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- } }
                    40 { if ($script:SelectedIndex -lt 7) { $script:SelectedIndex++ } }
                    13 {
                        switch ($script:SelectedIndex) {
                            0 { Search-Groups }
                            1 { Show-AllGroups }
                            2 { 
                                $group = Read-Host "Digite o nome do grupo"
                                $groupObj = Get-ADGroup -Identity $group
                                Show-GroupMembers $groupObj
                            }
                            3 { Add-UserToGroup }
                            4 { Remove-UserFromGroup }
                            5 { 
                                $group = Read-Host "Digite o nome do grupo"
                                $groupObj = Get-ADGroup -Identity $group
                                $members = Get-ADGroupMember -Identity $groupObj.SamAccountName | Where-Object {$_.objectClass -eq "user"} | Get-ADUser -Properties DisplayName, Mail, Department
                                Export-GroupMembersToEmail -Group $groupObj -Members $members
                            }
                            6 {
                                $group = Read-Host "Digite o nome do grupo"
                                $groupObj = Get-ADGroup -Identity $group
                                $members = Get-ADGroupMember -Identity $groupObj.SamAccountName | Where-Object {$_.objectClass -eq "user"} | Get-ADUser -Properties DisplayName, Mail, Department
                                Export-GroupMembersToCSV -Group $groupObj -Members $members
                                Write-Host "`nPressione qualquer tecla para continuar..."
                                $null = $Host.UI.RawUI.ReadKey()
                            }
                            7 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                        }
                    }
                    37 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                }
            }
            
            "tasks" {
                Show-TaskMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- } }
                    40 { if ($script:SelectedIndex -lt 5) { $script:SelectedIndex++ } }
                    13 {
                        switch ($script:SelectedIndex) {
                            0 { Create-ScheduledTask }
                            1 { List-Tasks }
                            2 { 
                                Write-Host "Edição de tarefa em desenvolvimento..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 2
                            }
                            3 { Remove-Task }
                            4 { Execute-TaskNow }
                            5 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                        }
                    }
                    37 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                }
            }
            
            "reports" {
                Show-ReportsMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- } }
                    40 { if ($script:SelectedIndex -lt 5) { $script:SelectedIndex++ } }
                    13 {
                        switch ($script:SelectedIndex) {
                            0 { Report-UsersByDepartment }
                            1 { Report-ExpiredPasswords }
                            2 { Report-InactiveUsers }
                            3 { Report-UsersWithoutManager }
                            4 { Report-UsersWithoutEmail }
                            5 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                        }
                    }
                    37 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                }
            }
            
            "utilities" {
                Show-UtilitiesMenu
                $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                switch ($key.VirtualKeyCode) {
                    38 { if ($script:SelectedIndex -gt 0) { $script:SelectedIndex-- } }
                    40 { if ($script:SelectedIndex -lt 4) { $script:SelectedIndex++ } }
                    13 {
                        switch ($script:SelectedIndex) {
                            0 { Test-ADConnection }
                            1 { Show-DomainStats }
                            2 { 
                                Write-Host "Sincronização com Exchange em desenvolvimento..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 2
                            }
                            3 { Generate-HtmlReport }
                            4 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                        }
                    }
                    37 { $script:CurrentMenu = "main"; $script:SelectedIndex = 0 }
                }
            }
        }
    }
}

Start-ADManager
