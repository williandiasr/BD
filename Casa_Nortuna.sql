drop database db_casanoturna;
create database db_casanoturna;
use db_casanoturna;

create table tbFuncionario(
FuncId int auto_increment primary key,
FuncNome varchar (250) not null,
FuncEmail varchar (250) not null
);

insert into tbFuncionario(FuncNome, FuncEmail) 
			values ('José Mario','jose@escola.com'),
				   ('Antonio Pedro','ant@escola.com'),
                   ('Monica Cascão','mos@escola.com');
                   
select * from tbFuncionario;

create table tbFuncionarioHistorico like tbFuncionario;
select * from tbFuncionarioHistorico;

-- drop table tbFuncionarioHistorico;
alter table tbFuncionarioHistorico modify FuncId int not null;
alter table tbFuncionarioHistorico drop primary key;

alter table tbFuncionarioHistorico add Atualizacao datetime;
alter table tbFuncionarioHistorico add Situacao varchar (20);

alter table tbFuncionarioHistorico add constraint PK_Id_FuncionarioHistorico primary key(FuncId,Atualizacao,Situacao);

delimiter //
create trigger TRG_FuncHistoricoInsert after insert on tbFuncionario 
	for each row
begin
	insert into tbFuncionarioHistorico
		set FuncId = new.FuncId,
			FuncNome = new.FuncNome,
            FuncEmail = new.FuncEmail,
            Atualizacao = current_timestamp(),
            Situacao = "Novo";
end;
//

insert into tbFuncionario (FuncNome, FuncEmail) values ('Will Jr', 'willj@escola.com');
select * from tbFuncionario;

describe tbFuncionarioHistorico;

delimiter //
create trigger TRG_FuncHistoricoDelete before delete on tbFuncionario 
	for each row
begin
	insert into tbFuncionarioHistorico
		set FuncId = old.FuncId,
			FuncNome = old.FuncNome,
            FuncEmail = old.FuncEmail,
            Atualizacao = current_timestamp(),
            Situacao = "Excluido";
end;
//



delete from tbFuncionario where FuncId=3;
select * from tbFuncionario;