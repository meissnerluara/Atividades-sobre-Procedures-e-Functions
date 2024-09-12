/*
ATIVIDADE BIBLIOTECA
LUARA GODOY MEISSNER PEREIRA – RGM: 11221103634
*/

create database bibliotec;
use bibliotec;

create table autor(
id int auto_increment primary key not null,
nome varchar(30) not null,
sobrenome varchar(30) not null
);

create table livro(
id int auto_increment primary key not null,
titulo varchar (30) not null, 
data_publicacao date not null,
autor_id int not null, 
foreign key (autor_id) references autor(id)
);

create table usuario(
id int auto_increment primary key not null,
nome varchar (40) not null,
cpf varchar (11) not null,
dt_nasc date, 
email varchar (50),
telefone varchar (11)
);

create table devolucoes(
id int auto_increment primary key,
id_livro int,
id_usuario int,
datadevolucao date,
datadevolucaoesperada date,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id)
);

create table multas(
id_multa int auto_increment primary key,
id_usuario int,
valormulta decimal(10, 2),
datamulta date,
foreign key (id_usuario) references usuario(id)
);

create table mensagens (
id int auto_increment primary key,
destinatario varchar(255) not null,
assunto varchar(255) not null,
corpo text,
data_envio datetime default current_timestamp
);

create table emprestimos (
id int auto_increment primary key,
id_livro int,
id_usuario int,
id_multa int,
id_devolucoes int,
foreign key (id_livro) references livro(id),
foreign key (id_usuario) references usuario(id),
foreign key (id_multa) references multas(id_multa),
foreign key (id_devolucoes) references devolucoes(id)
);

alter table livro add total_exemplares int not null;
alter table livro add status_livro varchar (15) not null;

create table livros_atualizados (
id_livro int auto_increment primary key,
titulo varchar(255) not null,
autor varchar(255) not null,
data_atualizacao datetime default current_timestamp
);

delimiter //
create trigger trigger_verificaratrasos
before insert on devolucoes
for each row
begin
    declare atraso int;
    set atraso = datediff(new.datadevolucaoesperada, new.datadevolucao);
    if atraso > 0 then
        -- dispara uma mensagem de alerta para o bibliotecário (exemplo genérico)
        insert into mensagens (destinatario, assunto, corpo)
        values ('bibliotecário', 'alerta de atraso', concat('o livro com id ', new.id_livro, ' não foi devolvido na data de devolução esperada.'));
    end if;
end;
//
delimiter ;

delimiter //
create trigger trigger_atualizarstatusemprestado
after insert on emprestimos
for each row
begin
    update livro
    set status_livro = 'emprestado'
    where id = new.id_livro;
end;
//
delimiter ;

delimiter //
create trigger trigger_atualizartotalexemplares
after insert on livro
for each row
begin
    update livro
    set total_exemplares = total_exemplares + 1
    where id = new.id;
end;
//
delimiter ;

delimiter //
create trigger trigger_registraratualizacaolivro
after update on livro
for each row
begin
    insert into livros_atualizados (id_livro, titulo, autor, data_atualizacao)
    values (old.id, old.titulo, old.autor_id, now());
end;
//
delimiter ;

alter table multas add media decimal(10,2);

-- procedures
 
delimiter $$
create procedure media_multas(in data_inicio date, in data_fim date, out media decimal(10,2))
begin
    select avg (valormulta) into media
    from multas
    where datamulta between data_inicio and data_fim;
end$$
delimiter ;

delimiter //
create procedure livros_devolvidos(in data_inicio date, in data_fim date, out qtd_livros_devolvidos int)
begin
    set qtd_livros_devolvidos = 0;
    select count(*) into qtd_livros_devolvidos
    from devolucoes
    where datadevolucao between data_inicio and data_fim;

end;
//
delimiter ;
 
delimiter //
create procedure livros_reservados(in data_inicio date, in data_fim date, out qtd_livros_reservados int)
begin
    set qtd_livros_reservados = 0;
    select count(*) into qtd_livros_reservados 
    from emprestimos e left join devolucoes d on e.id_devolucoes = d.id 
    where (d.datadevolucao is null or d.datadevolucao not between data_inicio and data_fim)and e.id_devolucoes is null;
end;
//
delimiter ;

delimiter //
create procedure busca_por_autor(in nome varchar(30), in sobrenome varchar(30))
begin
    select l.id, l.titulo, l.data_publicacao
    from livro l
    join autor a on l.autor_id = a.id
    where a.nome = nome and a.sobrenome = sobrenome;
end;
//
delimiter ;

delimiter //
create procedure novo_autor(in nome varchar(30), in sobrenome varchar(30))
begin
    insert into autor (nome, sobrenome)
    values (nome, sobrenome);
end;
//
delimiter ;

delimiter //
create procedure novo_livro(in titulo varchar(30), in data_publicacao date, in autor_id int, in total_exemplares int, in status_livro varchar(15))
begin
    insert into livro (titulo, data_publicacao, autor_id, total_exemplares, status_livro)
    values (titulo, data_publicacao, autor_id, total_exemplares, status_livro);
end;
//
delimiter ;

delimiter //
create procedure atualizar_usuario(in usuario_id int, in novo_nome varchar(40), in novo_cpf varchar(11), in nova_dt_nasc date, in novo_email varchar(50), in novo_telefone varchar(11))
begin
    update usuario
    set nome = novo_nome,
        cpf = novo_cpf,
        dt_nasc = nova_dt_nasc,
        email = novo_email,
        telefone = novo_telefone
    where id = usuario_id;
end;
//
delimiter ;

-- functions

delimiter //
create function livros_emprestados(id_usuario int) 
returns int
begin
    declare total int;
    select count(*) into total
    from emprestimos
    where id_usuario = id_usuario and id_devolucoes is null;
    return total;
end;
//
delimiter ;

delimiter //
create function status_livro(id_livro int) 
returns varchar(15)
begin
    declare status varchar(15);
    select status_livro into status
    from livro
    where id = id_livro;
    return status;
end;
//
delimiter ;
 
delimiter //
create function total_multas_usuario(id_usuario int) 
returns decimal(10,2)
begin
    declare total decimal(10,2);
    select coalesce(sum(valormulta), 0) into total
    from multas
    where id_usuario = id_usuario;
    return total;
end;
//
delimiter ;