#!/bin/bash

# ================================================================
# Script de Configuração do Ambiente de Desenvolvimento
# 
# Este script instala:
# - Neovim
# - Visual Studio Code (VSCode)
# ================================================================

# Cores para melhor legibilidade
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para exibir mensagens de progresso
show_message() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Função para verificar se um comando foi bem-sucedido
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Sucesso!${NC}"
    else
        echo -e "${YELLOW}⚠ Houve um problema. Verifique os logs acima.${NC}"
    fi
}

# Verifica se estamos em um sistema Debian/Ubuntu
if [ ! -f /etc/debian_version ]; then
    echo -e "${YELLOW}Atenção: Este script foi projetado para sistemas Debian/Ubuntu.${NC}"
    echo -e "${YELLOW}Pode ser necessário adaptá-lo para sua distribuição.${NC}"
    
    read -p "Deseja continuar mesmo assim? (s/n): " choice
    if [ "$choice" != "s" ]; then
        echo "Instalação cancelada."
        exit 1
    fi
fi

# Atualizar lista de pacotes
show_message "Atualizando repositórios..."
sudo apt update
check_status

# Instalar dependências essenciais
show_message "Instalando dependências essenciais..."
sudo apt install -y curl wget
check_status

# Instalar Neovim
show_message "Instalando Neovim..."
if command -v nvim &> /dev/null; then
    echo "Neovim já está instalado."
else
    sudo apt install -y neovim
    check_status
    echo "Neovim instalado. Versão: $(nvim --version | head -n 1)"
fi

# Instalar Visual Studio Code (VSCode)
show_message "Instalando Visual Studio Code (VSCode)..."
if command -v code &> /dev/null; then
    echo "VSCode já está instalado."
else
    # Instalar via Snap (opcional)
    read -p "Deseja instalar o VSCode via Snap? (s/n): " install_vscode_snap
    if [ "$install_vscode_snap" = "s" ]; then
        sudo snap install --classic code
    else
        # Instalar via repositório oficial
        sudo apt install -y software-properties-common apt-transport-https wget
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        sudo apt update
        sudo apt install -y code
    fi
    check_status
    echo "VSCode instalado. Versão: $(code --version | head -n 1)"
fi

# Mensagem de conclusão
echo -e "\n${GREEN}==================================${NC}"
echo -e "${GREEN}  Instalação concluída com sucesso!${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "\nVersões instaladas:"
echo -e "Neovim: $(nvim --version | head -n 1)"
echo -e "VSCode: $(code --version | head -n 1)"

echo -e "\n${YELLOW}IMPORTANTE:${NC}"
echo -e "Você pode configurar manualmente o Neovim e o VSCode conforme suas preferências."

echo -e "\n${GREEN}Obrigado por usar este script!${NC}"