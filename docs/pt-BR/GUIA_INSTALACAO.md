# Guia de Instalação e Configuração (Windows 11 + WSL2)

Este guia detalha o processo completo para rodar o **BR/ACC Open Graph** localmente em um ambiente Windows 11 utilizando o WSL2 (Windows Subsystem for Linux) e Docker.

---

## Passo 1: Pré-requisitos (No Windows)

1.  **Instale o Git:** [git-scm.com](https://git-scm.com/).
2.  **Instale o Docker Desktop:**
    *   Baixe em [docker.com](https://www.docker.com/products/docker-desktop/).
    *   Durante a instalação, marque a opção **"Use WSL 2 instead of Hyper-V (recommended)"**.
    *   Após a instalação e reinicialização, abra o Docker Desktop, vá em **Settings > Resources > WSL Integration** e verifique se a sua distro (ex: Ubuntu) está ativada.

---

## Passo 2: Clonando o Projeto (No Terminal WSL2)

Abra o seu terminal do **Ubuntu** (ou a sua distro WSL2) e siga estes comandos:

1.  **Crie uma pasta para seus projetos:**
    ```bash
    mkdir ~/projetos
    cd ~/projetos
    ```
2.  **Clone o repositório:**
    ```bash
    git clone https://github.com/World-Open-Graph/br-acc.git
    ```
3.  **Entre na pasta do projeto:**
    ```bash
    cd br-acc
    ```

---

## Passo 3: Preparando o Ambiente Linux (No Terminal WSL2)

Dentro do terminal do Ubuntu, instale a ferramenta `make` para gerenciar os comandos de execução:

```bash
sudo apt update
sudo apt install make -y
```

---

## Passo 4: Configuração e Execução

### 1. Configurar Variáveis de Ambiente
O projeto utiliza um arquivo `.env` para gerenciar senhas e URLs. Inicialize-o a partir do exemplo:
```bash
cp .env.example .env
```
*(A senha padrão do banco de dados configurada no `.env` é `bracc-local-dev`).*

### 2. Iniciar os Serviços (Docker)
Este comando vai baixar as imagens necessárias e subir a API, o Banco de Dados (Neo4j) e o Frontend:
```bash
make dev
```
*Aguarde alguns minutos. O primeiro build pode demorar dependendo da sua conexão.*

### 3. Popular o Banco de Dados (Seed)
Com os containers rodando (confira no Docker Desktop), execute o comando abaixo para carregar os dados de exemplo:
```bash
make seed
```

---

## Passo 5: Acesso aos Serviços

Após a conclusão do Passo 4, você poderá acessar:

*   **Interface Gráfica (Frontend):** [http://localhost:3000](http://localhost:3000)
*   **API (Saúde do sistema):** [http://localhost:8000/health](http://localhost:8000/health)
*   **Neo4j Browser (Administração):** [http://localhost:7474](http://localhost:7474)
    *   **Login:** `neo4j`
    *   **Senha:** `bracc-local-dev`

---

## Comandos Úteis (Makefile)

Execute estes comandos sempre na raiz do projeto dentro do WSL:

*   `make dev`: Inicia todos os serviços no Docker.
*   `make stop`: Para os serviços sem apagar os dados.
*   `make seed`: Carrega dados de teste no Neo4j.
*   `make clean`: Para tudo e remove os volumes do banco (reseta o banco de dados).
*   `make check`: Roda ferramentas de qualidade (lint e tipos).

---

## Como Baixar Dados Reais

O projeto possui scripts específicos para baixar bases de dados públicas reais. Esses scripts salvam os arquivos na pasta `data/`, que é então lida pelo motor de ETL.

### 1. Baixando bases via Scripts (Pasta `scripts/`)
Existem scripts individuais para fontes que não possuem download automático via CLI:

*   **Comprasnet (Contratos Federais):**
    ```bash
    python3 scripts/download_comprasnet.py 2024
    ```
*   **Datasus (Dados de Saúde):**
    ```bash
    python3 scripts/download_datasus.py
    ```
*   **DOU (Diário Oficial da União):**
    ```bash
    bash scripts/download_dou.sh
    ```

### 2. Baixando CNPJ via CLI (Recomendado para início)
Para a base de CNPJs (Receita Federal), use o comando integrado:
```bash
cd etl
uv run bracc-etl download --source cnpj --files 1
```

### 3. Carregando os dados no Neo4j
Após o download, os arquivos estarão em `data/<fonte>`. Para processá-los e enviá-los ao grafo:
```bash
cd etl
uv run bracc-etl run --source <nome_da_fonte> --neo4j-password bracc-local-dev
```
*(Substitua `<nome_da_fonte>` por `cnpj`, `comprasnet`, `tse`, etc.)*

---

## Solução de Problemas (Troubleshooting)

### Erro `Invalid value for NEO4J_AUTH: 'neo4j/'`
Se ao rodar `make dev` o container `bracc-neo4j` falhar com esse erro, verifique se o arquivo `.env` existe na raiz do projeto e se a variável `NEO4J_PASSWORD` está preenchida corretamente.
O comando `make dev` agora carrega o `.env` automaticamente, mas o arquivo precisa estar presente.
