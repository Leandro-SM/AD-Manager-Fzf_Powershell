# 🖥️ AD Manager CLI com navegação Fzf

**AD Manager CLI** é uma ferramenta interativa em PowerShell para administração do Active Directory (AD) diretamente pelo terminal. Com navegação estilo `ani-cli`, permite gerenciar usuários, grupos, criar tarefas agendadas, gerar relatórios e muito mais, com interface totalmente navegável por teclado.

![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![ActiveDirectory](https://img.shields.io/badge/AD-RSAT-orange)

O módulo fzf permite exibir, paginar e navegar em uma lista de itens da interface com teclas de atalho.

---

## ✨ Funcionalidades

### 👥 Gerenciamento de Usuários
- Busca interativa por nome, login ou email
- Listagem paginada com navegação por teclado (↑/↓/←/→)
- Criação, edição e exclusão lógica
- Reset de senha com confirmação
- Habilitar/desabilitar conta
- Visualização de grupos do usuário
- Envio de e-mail direto (SMTP configurável)

### 📁 Gerenciamento de Grupos
- Busca e listagem de grupos
- Visualização de membros com paginação
- Adicionar/remover usuários
- Exportação de membros para:
  - **E-mail** (relatório HTML)
  - **CSV** (para análise em Excel)

### ⏰ Tarefas Agendadas
- Criação de tarefas com frequência: **daily**, **weekly**, **monthly**
- Integração com o **Agendador de Tarefas do Windows**
- Armazenamento local em JSON
- Execução manual ou automática
- Remoção de tarefas existentes

### 📊 Relatórios Rápidos
- Usuários por departamento
- Contas com senha expirada
- Usuários inativos (90+ dias)
- Usuários sem **manager** definido
- Usuários sem e-mail configurado

### 🔧 Utilitários AD
- Teste de conectividade com o domínio
- Estatísticas do domínio (usuários, computadores, grupos)
- Geração de relatório completo em **HTML** (salvo na área de trabalho)

---

## 📋 Pré-requisitos

- **Windows** 10/11 ou Windows Server 2016+
- **PowerShell 5.1** ou superior
- **Módulo Active Directory** (RSAT-AD-PowerShell)
  ```powershell
  # Instalar via PowerShell como administrador
  Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
Permissões administrativas no domínio para algumas operações (reset de senha, criar usuário, etc.)

🚀 Instalação
Clone o repositório

bash
git clone https://github.com/seu-usuario/ad-manager-cli.git
cd ad-manager-cli
Execute o script

powershell
powershell -ExecutionPolicy Bypass -File .\ADManager.ps1
⚠️ Importante: Execute o script em um PowerShell com privilégios administrativos para todas as funcionalidades funcionarem corretamente.

🎮 Como Usar
Navegação (estilo ani-cli)
↑ / ↓ – Navegar entre opções do menu

Enter – Selecionar opção

← (seta esquerda) – Voltar ao menu anterior

q – Sair do programa

h – Exibir ajuda

Exemplos de uso
🔍 Buscar usuário
Menu principal → Gerenciar Usuários → Buscar usuário

Digite parte do nome, login ou e-mail

Navegue pelos resultados, pressione Enter para ver detalhes

📧 Exportar membros de um grupo
Gerenciar Grupos → Exportar membros para email

Informe o nome do grupo

Digite o e-mail do destinatário

Configure o servidor SMTP quando solicitado

⏰ Criar tarefa agendada
Tarefas Agendadas → Criar nova tarefa

Nome da tarefa, grupo AD, e-mail de destino

Escolha frequência (daily/weekly/monthly) e horário

A tarefa será registrada no Agendador de Tarefas do Windows

⚙️ Configuração SMTP (para envio de e-mails)
Ao exportar membros por e-mail ou enviar mensagens para usuários, você precisará informar:

Servidor SMTP (ex: smtp.empresa.com)

Porta (padrão: 587)

E-mail remetente (ex: admanager@dominio.com)

O script tentará enviar usando essas configurações. Se falhar, exibirá o erro para você ajustar.

💡 Dica: você pode modificar o script para usar credenciais fixas ou variáveis de ambiente.

📁 Estrutura de Arquivos Gerados
Arquivo/Pasta	Descrição
$env:USERPROFILE\ADManager_Tasks.json	Armazenamento local das tarefas agendadas
$env:TEMP\task_*.ps1	Scripts temporários das tarefas
$env:TEMP\relatorio_*.txt	Relatórios gerados por tarefas agendadas
$env:TEMP\ADManager_Task.log	Log de execução das tarefas
Desktop\AD_Report_*.html	Relatório completo gerado pelo utilitário
Desktop\grupo_*.csv	Exportação de membros de grupo em CSV
🛠️ Personalização
Você pode facilmente ajustar o script para seu ambiente:

Cores – Modifique o dicionário $script:Colors

SMTP padrão – Altere os valores fixos na função Export-GroupMembersToEmail

Tamanho da página – Altere $script:PageSize (padrão 10)

Limite de inatividade – Modifique AddDays(-90) na função Report-InactiveUsers

