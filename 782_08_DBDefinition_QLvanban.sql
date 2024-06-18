--Tạo cơ sơ dữ liệu
create database document

--Các câu lệnh tạo bảng,khóa chính
CREATE SEQUENCE document_in_doc_id_seq1;

create table document_in (
	doc_id bigint primary key default nextval('document_in_doc_id_seq1'::regclass) not null,
	doc_name varchar(50) not null,
	doc_content text,
	textbook_id integer,
	user_id varchar(5),
	user_maker varchar(5),
	user_checker varchar(5),
	org_sender varchar(3) not null,
	org_receiver varchar(3) not null,
	doc_type varchar(1),
	status varchar(1),
	date_in date
);

ALTER SEQUENCE document_in_doc_id_seq1
OWNED BY document_in.doc_id;

create table document_out (
	doc_id bigint primary key default nextval('document_in_doc_id_seq1'::regclass) not null,
	doc_name varchar(50) not null,
	doc_content text,
	textbook_id integer,
	user_id varchar(5),
	user_maker varchar(5),
	user_checker varchar(5),
	org_sender varchar(3) not null,
	org_receiver varchar(3) not null,
	doc_type varchar(1),
	status varchar(1),
	date_out date
);

ALTER SEQUENCE document_in_doc_id_seq1
OWNED BY document_out.doc_id;

create table organization (
	org_id varchar(3) primary key not null,
	org_name varchar(100) not null,
	address varchar(200) not null,
	description varchar(200)
)

create table users (
	user_id varchar(5) primary key not null,
	username varchar(100) not null,
	org_id varchar(3) references organization(org_id) not null,
	role_id varchar(2) not null
)

CREATE SEQUENCE textbook_textbook_id_seq;

create table textbook (
	textbook_id integer primary key default nextval('textbook_textbook_id_seq'::regclass) not null,
	textbook_name varchar(20) not null,
	textbook_type varchar(1) not null,
	org_id varchar(3) not null,
	user_id varchar(5)
);

--Thêm mới đơn vị vào bảng organization--
insert into organization(org_id, org_name, address, description)
values('120', 'Chi nhánh Hà Nội', '4B Lê Thánh Tông Hà Nội', ' '),
('130', 'Chi nhánh TPHCM', '134 Nguyễn Công Trứ TPHCM', ' '),
('210', 'Chi nhánh Đà Nẵng', '7 Lý Tự Trọng', ' '),
('310', 'Chi nhánh Cần Thơ', '5 Lê Duẩn', ' ')

-- Thêm người sử dụng và các vai trò tương ứng vào bảng users
insert into users(user_id, username, org_id, role_id)
values
('12001','Lê Huy Phong','120','01'),
('12002','Nguyễn Văn Hạnh','120','02'),
('12003','Trần Huy Tuấn','120','03'),
('12004','Đào Mạnh Tuấn','120','04'),
('13001','Trần Huy Liệu','130','01'),
('13002','Lê Hồng Anh','130','02'),
('13003','Trương Ngọc Khánh','130','03'),
('13004','Trần Bảo Phúc','130','04'),
('21001','Lại Thanh Đức','210','01'),
('21002','Nguyễn Anh Đức','210','02'),
('21003','Hoàng Mai Anh','210','03'),
('21004','Hoàng Quỳnh Lan','210','04'),
('31001','Mai Minh Ngọc','310','01'),
('31002','Trần Phương Anh','310','02'),
('31003','Nguyễn Thu Hà','310','03'),
('31004','Trịnh Nguyệt Anh','310','04')

-- Thêm sổ văn bản đi, đến, nội bộ cho các đơn vị
insert into textbook(textbook_name, textbook_type, org_id, user_id)
values('Sổ văn bản đi', '1', '120', '12003'),
('Sổ văn bản đến', '2', '120', '12003'),
('Sổ văn bản nội bộ', '3', '120', '12003'),
('Sổ văn bản đi', '1', '130', '13003'),
('Sổ văn bản đến', '2', '130', '13003'),
('Sổ văn bản nội bộ', '3', '130', '13003'),
('Sổ văn bản đi', '1', '210', '21003'),
('Sổ văn bản đến', '2', '210', '21003'),
('Sổ văn bản nội bộ', '3', '210', '21003'),
('Sổ văn bản đi', '1', '310', '31003'),
('Sổ văn bản đến', '2', '310', '31003'),
('Sổ văn bản nội bộ', '3', '310', '31003')

--Thêm dữ liệu cho văn bản đi
insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('Triển khai phần mềm diệt virus cho các máy tính', 'Trong bối cảnh tình trạng virus máy tính lây lan rất mạnh trong mạng nội bộ của công ty, tổng công ty đề nghị chi nhánh Hà Nội tổ chức diệt virus tại các máy tính cá nhân. Thời gian thực hiện trước 1/6/2024', 1,'2','12002', '1', '120', '130', CURRENT_DATE),
('Natural Language Processing', 'This paper discusses Natural Language Processing (NLP) and its applications, including sentiment analysis, language translation, and summarization.', 1, '2', '12002', '4', '120', '210', CURRENT_DATE),
('Survey on Cloud Computing', 'This document provides a comprehensive survey on cloud computing technologies, benefits, security issues, and future trends.', 10, '1', '31002', '1', '310', '120', CURRENT_DATE),
('Internet of Things (IoT)', 'This paper explores the concept of Internet of Things (IoT) and its applications in various fields such as smart homes, healthcare, and industrial automation.', 4, '2', '13002', '3', '130', '120', CURRENT_DATE),
('Cybersecurity Fundamentals', 'This document discusses the fundamentals of cybersecurity, including encryption, network security, and risk management.', 7, '3', '21002', '2', '210', '310', CURRENT_DATE),
('Artificial Intelligence Applications', 'This paper covers the various applications of Artificial Intelligence (AI) in different sectors such as healthcare, finance, and transportation.', 4, '1', '13002', '2', '130', '310', CURRENT_DATE);

-- Thêm dữ liệu cho văn bản đến
insert into document_in(doc_name, doc_content, textbook_id, doc_type, user_id, status, org_sender, org_receiver, date_in)
values
('Triển khai phần mềm diệt virus cho các máy tính', 'Trong bối cảnh tình trạng virus máy tính lây lan rất mạnh trong mạng nội bộ của công ty, tổng công ty đề nghị chi nhánh Hà Nội tổ chức diệt virus tại các máy tính cá nhân. Thời gian thực hiện trước 1/6/2024', 5,'2','13003', '1', '120', '130', CURRENT_DATE),
('Meeting Minutes', 'The minutes from the last meeting of the board of directors, including topics discussed and action items.', 5, '1', '13002', '1', '310', '130', CURRENT_DATE),
('Urgent Contract Review', 'A contract that requires immediate review by the legal team. It outlines the terms and conditions of a new partnership.', 2, '2', '12002', '2', '210', '120', CURRENT_DATE),
('Confidential Report', 'A detailed confidential report on the company’s operational performance over the last quarter.', 5, '3', '13002', '3', '120', '130', CURRENT_DATE),
('Employee Feedback', 'Feedback forms from employees regarding the new remote working policy implemented last month.', 8, '1', '21002', '4', '130', '210', CURRENT_DATE),
('Investor Proposal', 'A proposal from potential investors outlining their offer and requested terms for investment.', 11, '2', '31002', '1', '120', '310', CURRENT_DATE);
