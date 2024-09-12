/*
ATIVIDADE TEATRO
LUARA GODOY MEISSNER PEREIRA – RGM: 11221103634
*/

create database teatro;
use teatro;

create table pecas_teatro(
id_peca int auto_increment primary key not null,
nome_peca varchar (40),
descricao varchar (100),
duracao TIME
);

delimiter //
create function calcular_media_duracao(id_peca int)
returns decimal(5, 2)
begin
    declare media_duracao decimal(5, 2);
    select avg(time_to_sec(duracao) / 60) into media_duracao
    from pecas_teatro
    where id_peca = id_peca;
    return media_duracao;
end //
delimiter ;

create table apresentacao(
    id_apresentacao int auto_increment primary key not null,
    data_hora datetime,
	id_peca int,
    foreign key (id_peca) references pecas_teatro(id_peca)
);

delimiter //
create function verificar_disponibilidade(data_hora datetime)
returns boolean
begin
    declare disponibilidade boolean;
    select case
        when count(*) > 0 then true
        else false
    end into disponibilidade
    from apresentacao
    where data_hora = data_hora;
    return disponibilidade;
end //
delimiter ;

delimiter //
create procedure agendar_peca(
    in nome_peca varchar(40),
    in descricao varchar(100),
    in duracao time,
    in data_hora datetime
)
begin
    declare id_nova_peca int;
    declare media_duracao decimal(5, 2);
    declare disponibilidade boolean;
    set disponibilidade = verificar_disponibilidade(data_hora);
    if not disponibilidade then
        insert into pecas_teatro (nome_peca, descricao, duracao)
        values (nome_peca, descricao, duracao);
		set id_nova_peca = last_insert_id();
		set media_duracao = calcular_media_duracao(id_nova_peca);
		insert into apresentacao (id_peca, data_hora)
        values (id_nova_peca, data_hora);
    end if;
end //
delimiter ;

insert into pecas_teatro(nome_peca, descricao, duracao) values
('Wicked', 'A História das Bruxas de Oz', '01:00:00'),
('Auto da Compadecida', 'A história de João Grilo e Chicó', '02:00:00'),
('Romeu e Julieta', 'Uma tragédia de Shakespeare', '02:30:00');

insert into apresentacao(data_hora, id_peca) values
('2024-09-14 21:00:00', 1),
('2024-09-15 16:50:00', 2),
('2024-09-15 19:30:00', 3);

call agendar_peca('Wicked', 'A História das Bruxas de Oz', '01:00:00', '2024-09-14 12:00:00');

select * from apresentacao;
select * from pecas_teatro;