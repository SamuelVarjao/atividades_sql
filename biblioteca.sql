-- CREATE DATABASE BIBLIOTECA;
use biblioteca;


CREATE TABLE LIVROS(
	ID_LIVRO INT PRIMARY KEY AUTO_INCREMENT,
    NOME_LIVRO VARCHAR(100),
    DATA_PUBLICACAO DATE
);

CREATE TABLE AUTOR(
	ID_AUTOR INT PRIMARY KEY AUTO_INCREMENT,
    NOME_AUTOR VARCHAR(100),
    ID_LIVRO INT,
);

CREATE TABLE LIVROS_AUTOR(
	ID_AUTOR INTEGER,
    ID_LIVRO INTEGER,
    PRIMARY KEY (ID_AUTOR, ID_LIVRO),
    CONSTRAINT FK_AUTOR FOREIGN KEY(ID_AUTOR) REFERENCES AUTOR(ID_AUTOR),
    CONSTRAINT FK_LIVRO FOREIGN KEY(ID_LIVRO) REFERENCES LIVROS(ID_LIVRO)
);

CREATE TABLE USUARIOS(
	ID_USUARIO INT PRIMARY KEY auto_increment,
    NOME_USUARIO VARCHAR(50),
    DATA_NASCIMENTO DATE,
    CPF VARCHAR(12),
    TELEFONE VARCHAR(20)
);

CREATE TABLE LOCACAO (
	ID_LOCACAO INT PRIMARY KEY AUTO_INCREMENT,
    DATA_LOCACAO DATE,
    ID_USUARIO INT,
    ID_LIVRO INT,
    
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (ID_LIVRO) REFERENCES LIVROS(ID_LIVRO)
);

CREATE TABLE DEVOLUCOES(
	ID_DEVOLUCAO INT AUTO_INCREMENT PRIMARY KEY,
    ID_LIVRO INT,
    ID_USUARIO INT,
    DATA_DEVOLUCAO DATE,
    DATA_DEVOLUCAO_ESPERADA DATE,
    FOREIGN KEY (ID_LIVRO) REFERENCES LIVROS(ID_LIVRO),
    FOREIGN KEY(ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO)
);

CREATE TABLE MULTAS (
	ID_MULTAS INT AUTO_INCREMENT PRIMARY KEY,
    ID_USUARIO INT,
    VALOR_MULTAS DECIMAL (10,2),
    DATA_MULTA DATE,
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO)
);

CREATE TABLE Mensagens (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Destinatario VARCHAR(255) NOT NULL,
    Assunto VARCHAR(255) NOT NULL,
    Corpo TEXT,
    DataEnvio DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Livros_Atualizados (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_Livro INT NOT NULL,
    Titulo VARCHAR(255) NOT NULL,
    Autor VARCHAR(255),
    DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Livros_Excluidos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_Livro INT NOT NULL,
    Titulo VARCHAR(255) NOT NULL,
    Autor VARCHAR(255),
    DataExclusao DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO LIVROS (NOME_LIVRO, DATA_PUBLICACAO) VALUES 
('Livro A', '2020-01-01'),
('Livro B', '2021-02-15'),
('Livro C', '2022-03-20'),
('O Senhor dos Anéis', '1954-07-29'),
('1984', '1949-06-08');


INSERT INTO AUTOR (NOME_AUTOR, ID_LIVRO) VALUES 
('Autor 1', 1),
('Autor 2', 1),
('Autor 3', 2),
('Autor 4', 2),
('Autor 5', 3),
('Autor 6', 3);

INSERT INTO LIVROS_AUTOR (ID_AUTOR, ID_LIVRO) VALUES 
(1, 1),  
(1, 2),  
(2, 1),  
(2, 3), 
(3, 2),  
(3, 3);  

INSERT INTO USUARIOS (NOME_USUARIO, DATA_NASCIMENTO, CPF, TELEFONE) VALUES
('Carlos Silva', '1990-05-12', '12345678901', '(11) 98765-4321'),
('Ana Oliveira', '1985-07-24', '98765432100', '(21) 91234-5678'),
('Pedro Santos', '1992-10-30', '12312312312', '(31) 99876-5432'),
('Mariana Costa', '1995-02-15', '45645645645', '(41) 93456-7890'),
('João Souza', '1988-03-22', '78978978978', '(51) 94567-8901');


INSERT INTO LOCACAO (DATA_LOCACAO, ID_USUARIO, ID_LIVRO) VALUES
('2023-08-01', 1, 1),
('2023-08-02', 2, 2),
('2023-08-03', 3, 3),
('2023-08-04', 4, 4),
('2023-08-05', 5, 5);

INSERT INTO DEVOLUCOES (ID_LIVRO, ID_USUARIO, DATA_DEVOLUCAO, DATA_DEVOLUCAO_ESPERADA) VALUES
(1, 1, '2023-08-10', '2023-08-09'),
(2, 2, '2023-08-11', '2023-08-10'),
(3, 3, '2023-08-12', '2023-08-11'),
(4, 4, '2023-08-13', '2023-08-12'),
(5, 5, '2023-08-14', '2023-08-13');

INSERT INTO MULTAS (ID_USUARIO, VALOR_MULTAS, DATA_MULTA) VALUES
(1, 15.50, '2023-08-12'),
(2, 10.00, '2023-08-13'),
(3, 7.75, '2023-08-14'),
(4, 20.00, '2023-08-15'),
(5, 5.50, '2023-08-16');

INSERT INTO LIVROS (NOME_LIVRO, DATA_PUBLICACAO) VALUES 
('Livro D', '2019-05-05'),
('Livro E', '2018-10-10');




-- TRIGGERS
DELIMITER //

CREATE TRIGGER trg_calcula_multa
AFTER INSERT ON DEVOLUCOES
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    DECLARE valor_multa DECIMAL(10, 2);

    -- Calcula o atraso em dias
    SET atraso = DATEDIFF(NEW.DATA_DEVOLUCAO, NEW.DATA_DEVOLUCAO_ESPERADA);

    -- Verifica se houve atraso
    IF atraso > 0 THEN
        -- Calcula o valor da multa (por exemplo, R$ 2,00 por dia de atraso)
        SET valor_multa = atraso * 2.00;

        -- Insere o registro de multa na tabela Multas
        INSERT INTO MULTAS (ID_USUARIO, VALOR_MULTAS, DATA_MULTA)
        VALUES (NEW.ID_USUARIO, valor_multa, NOW());
    END IF;
END //

DELIMITER //
 CREATE TRIGGER Trigger_VerificarAtrasos
BEFORE INSERT ON Devolucoes
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    -- Calculao atraso em dias
    SET atraso= DATEDIFF(NEW.DATA_DEVOLUCAO_ESPERADA, DATA_DEVOLUCAO);
    -- Verificase há atraso
    IF atraso> 0 THEN
        -- Disparauma mensagem de alerta para o bibliotecário (exemplo genérico)
        INSERT INTO Mensagens (Destinatario, Assunto, Corpo)
        VALUES ('Bibliotecário', 'Alerta de Atraso', CONCAT('O livro com ID ', NEW.ID_Livro, ' não foi devolvido na data de devolução esperada.'));
    END IF;
END;
//

DELIMITER //
CREATE TRIGGER Trigger_AtualizarStatusEmprestado
AFTER INSERT ON LOCACAO
FOR EACH ROW
BEGIN
    UPDATE Livros
    SET StatusLivro= 'Emprestado'
    WHERE ID = NEW.ID_Livro;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER Trigger_AtualizarTotalExemplares
AFTER INSERT ON Livros
FOR EACH ROW
BEGIN
    UPDATE LIVROS
    SET TotalExemplares= TotalExemplares + 1
    WHERE ID_LIVRO = NEW.ID_LIVRO;
END;
//

DELIMITER //
CREATE TRIGGER Trigger_RegistrarAtualizacaoLivro
AFTER UPDATE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Livros_Atualizados (ID_Livro, Titulo, DataAtualizacao)
    VALUES (OLD.ID_LIVRO, OLD.NOME_LIVRO, NOW());
END;
//

DELIMITER //
CREATE TRIGGER Trigger_RegistrarExclusaoLivro
AFTER DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Livros_Excluidos (ID_Livro, Titulo, Autor, DataExclusao)
    VALUES (OLD.ID_LIVRO, OLD.NOME_LIVRO, NOW());
END;
//

SELECT L.NOME_LIVRO, A.NOME_AUTOR,LA.ID_AUTOR,LA.ID_LIVRO FROM AUTOR A
JOIN LIVROS L ON A.ID_AUTOR = L.ID_LIVRO
JOIN LIVROS_AUTOR LA ON A.ID_AUTOR =LA.ID_AUTOR;

-- count
SELECT COUNT(nome_livro) as total FROM LIVROS ;

-- PROCEDURES
DELIMITER $$
CREATE PROCEDURE TESTE(IN ID INT) 
BEGIN 
	SELECT * FROM LIVROS WHERE ID_LIVRO= ID;
END
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE LivrosReservadosPorPeriodo(IN DataInicio DATE, IN DataFim DATE)
BEGIN
    SELECT COUNT(*) AS QuantidadeReservada
    FROM LOCACAO
    WHERE DATA_LOCACAO BETWEEN DataInicio AND DataFim;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE MediaMultasPorPeriodo(IN DataInicio DATE, IN DataFim DATE)
BEGIN
    SELECT AVG(VALOR_MULTAS) AS MediaMultas
    FROM MULTAS
    WHERE DATA_MULTA BETWEEN DataInicio AND DataFim;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION LivroDisponivel(ID_Livro INT) RETURNS BOOLEAN
BEGIN
    DECLARE status VARCHAR(20);
    SELECT StatusLivro INTO status
    FROM LIVROS
    WHERE ID_LIVRO = ID_Livro;

    RETURN status = 'Disponível';
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ListarLivrosAtrasados()
BEGIN
    SELECT L.NOME_LIVRO, U.NOME_USUARIO, D.DATA_DEVOLUCAO_ESPERADA
    FROM DEVOLUCOES D
    JOIN LIVROS L ON D.ID_LIVRO = L.ID_LIVRO
    JOIN USUARIOS U ON D.ID_USUARIO = U.ID_USUARIO
    WHERE D.DATA_DEVOLUCAO > D.DATA_DEVOLUCAO_ESPERADA;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarLocacaoPorUsuario(IN ID_Usuario INT)
BEGIN
    SELECT L.NOME_LIVRO, LOC.DATA_LOCACAO
    FROM LOCACAO LOC
    JOIN LIVROS L ON LOC.ID_LIVRO = L.ID_LIVRO
    WHERE LOC.ID_USUARIO = ID_Usuario;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION DiasDeAtraso(ID_Devolucao INT) RETURNS INT
BEGIN
    DECLARE atraso INT;
    SELECT DATEDIFF(DATA_DEVOLUCAO, DATA_DEVOLUCAO_ESPERADA)
    INTO atraso
    FROM DEVOLUCOES
    WHERE ID_DEVOLUCAO = ID_Devolucao;

    RETURN IF(atraso > 0, atraso, 0);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE LivrosMaisLocados()
BEGIN
    SELECT L.NOME_LIVRO, COUNT(*) AS TotalLocacoes
    FROM LOCACAO LOC
    JOIN LIVROS L ON LOC.ID_LIVRO = L.ID_LIVRO
    GROUP BY L.NOME_LIVRO
    ORDER BY TotalLocacoes DESC
    LIMIT 5;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION CalcularMultaPorAtraso(ID_Devolucao INT) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE atraso INT;
    DECLARE valor_multa DECIMAL(10, 2);
    
    -- Calcula dias de atraso
    SELECT DATEDIFF(DATA_DEVOLUCAO, DATA_DEVOLUCAO_ESPERADA)
    INTO atraso
    FROM DEVOLUCOES
    WHERE ID_DEVOLUCAO = ID_Devolucao;
    
    -- Se houver atraso, calcula a multa
    IF atraso > 0 THEN
        SET valor_multa = atraso * 2.00;  -- Exemplo de R$ 2,00 por dia de atraso
    ELSE
        SET valor_multa = 0;
    END IF;
    
    RETURN valor_multa;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE LivrosDevolvidosNoPrazo()
BEGIN
    SELECT L.NOME_LIVRO, U.NOME_USUARIO, D.DATA_DEVOLUCAO
    FROM DEVOLUCOES D
    JOIN LIVROS L ON D.ID_LIVRO = L.ID_LIVRO
    JOIN USUARIOS U ON D.ID_USUARIO = U.ID_USUARIO
    WHERE D.DATA_DEVOLUCAO <= D.DATA_DEVOLUCAO_ESPERADA;
END$$
DELIMITER ;


-- DROP DATABASE BIBLIOTECA;








