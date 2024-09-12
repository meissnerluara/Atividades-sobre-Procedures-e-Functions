/*
ATIVIDADE HALLOWEEN
LUARA GODOY MEISSNER PEREIRA – RGM: 11221103634
*/
 
create database halloween;
use halloween;
 
create table usuários (
id int auto_increment primary key not null,
nome varchar (50),
email varchar (50),
idade int
)
 
-- defina o delimitador para evitar conflitos com ponto e vírgula
delimiter $$
create procedure insereusuariosaleatorios()
begin
    declare i int default 0;
    -- loop para inserir 10.000 registros
    while i < 10000 do
        -- gere dados aleatórios para os campos
        set @nome := concat('usuario', i);
        set @email := concat('usuario', i, '@exemplo.com');
        set @idade := floor(rand() * 80) + 18;  -- gera uma idade entre 18 e 97 anos
        -- insira o novo registro na tabela de usuários
        insert into usuários (nome, email, idade) values (@nome, @email, @idade);
        -- incrementa o contador
        set i = i + 1;
    end while;
end$$ 
-- restaure o delimitador padrão
delimiter ;