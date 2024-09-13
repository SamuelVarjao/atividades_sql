-- CREATE DATABASE TEATRO;
USE TEATRO;

-- 1
CREATE TABLE PECAS_TEATRO(
	ID_PECA INT  PRIMARY KEY AUTO_INCREMENT,
    NOME_PECA VARCHAR(100),
    DESCRICAO VARCHAR(800),
    DURACAO INT,
    TEMA VARCHAR(30),
    HORARIO  TIME
);

INSERT INTO PECAS_TEATRO (NOME_PECA, DESCRICAO, DURACAO, TEMA, HORARIO) VALUES
('O Fantasma da Ópera', 'Um clássico musical sobre um triângulo amoroso entre uma jovem cantora, seu mentor e um nobre apaixonado, situado em um teatro de ópera.', 160, 'Drama', '19:00:00'),
('Romeu e Julieta', 'A famosa tragédia de William Shakespeare sobre o amor proibido entre dois jovens de famílias rivais.', 120, 'Tragédia', '20:00:00'),
('A Comédia dos Erros', 'Uma das primeiras comédias de Shakespeare, repleta de mal-entendidos e confusões de identidade.', 90, 'Comédia', '18:00:00'),
('Os Miseráveis', 'Adaptação do clássico romance de Victor Hugo sobre a luta pela justiça e redenção na França do século XIX.', 180, 'Drama', '21:00:00'),
('O Mágico de Oz', 'A jornada de Dorothy e seus amigos em busca do Mágico de Oz, em uma peça cheia de música e magia.', 110, 'Fantasia', '17:00:00'),
('Hamlet', 'Um drama sobre vingança, corrupção e loucura, onde o príncipe Hamlet busca justiça pela morte de seu pai.', 140, 'Tragédia', '20:30:00'),
('O Auto da Compadecida', 'Uma comédia brasileira que combina humor e crítica social em uma história envolvente no sertão nordestino.', 100, 'Comédia', '19:30:00'),
('Esperando Godot', 'Uma peça de teatro do absurdo que reflete sobre a condição humana, enquanto dois personagens esperam alguém chamado Godot.', 90, 'Drama', '18:30:00'),
('A Megera Domada', 'Uma comédia de Shakespeare que trata do embate entre gêneros e de uma mulher independente e desafiadora.', 110, 'Comédia', '17:30:00'),
('A Vida é Sonho', 'Uma peça espanhola sobre o destino, livre arbítrio e a natureza da realidade.', 130, 'Drama', '21:30:00');

-- 2
DELIMITER $$
CREATE PROCEDURE CALCULAR_MEDIA_DURACAO(IN ID INT) 
BEGIN 
	SELECT AVG (DURACAO) FROM PECAS_TEATRO WHERE ID_PECA=ID;
END
DELIMITER $$

-- 3
DELIMITER $$
CREATE PROCEDURE VERIFICAR_DISPONIBILIDADE(IN HORA VARCHAR(10))
BEGIN
	SELECT TIME(HORARIO) FROM PECAS_TEATRO AS HORARIO_DISNPONIVEL WHERE HORARIO=HORA;
END
DELIMITER $$
CALL VERIFICAR_DISPONIBILIDADE('20:00:00')

-- 4
DELIMITER $$
CREATE PROCEDURE AGENDAR_PECA 
(
    IN PAR_NOME_PECA VARCHAR(100), 
    IN PAR_DESCRICAO VARCHAR(800), 
    IN PAR_DURACAO INT, 
    IN PAR_TEMA VARCHAR(50), 
    IN PAR_DATA_HORA VARCHAR(10)
)
BEGIN
    INSERT INTO PECAS_TEATRO (NOME_PECA, DESCRICAO, DURACAO, TEMA, HORARIO)
    VALUES (PAR_NOME_PECA, PAR_DESCRICAO, PAR_DURACAO, PAR_TEMA, PAR_DATA_HORA);
    CALL VERIFICAR_DISPONIBILIDADE(PAR_DATA_HORA)
    
   SELECT PECAS.*, (SELECT AVG(DURACAO) FROM PECAS_TEATRO) AS MEDIA_DURACAO FROM 
    PECAS_TEATRO PECAS  WHERE PECAS.NOME_PECA= PAR_NOME_PECA
END
DELIMITER $$

-- 5
-- SET SQL_SAFE_UPDATES = 0;
-- DELETE FROM PECAS_TEATRO WHERE NOME_PECA = 'Hamlet'
CALL AGENDAR_PECA('Hamlet', 'Uma tragédia de Shakespeare sobre o príncipe da Dinamarca.', 180, 'Tragédia', '19:00:00');
