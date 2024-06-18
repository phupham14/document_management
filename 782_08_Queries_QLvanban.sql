/*Phạm Trần Nguyên Phú*/
-- Nhân viên Nguyễn Văn Hạnh thêm mới 1 văn bản đi tại chi nhánh Hà Nội gửi chi nhánh TPHCM với kiểu văn bản khẩn. Văn bản này
-- được trình lên giám đốc đơn vị là ông Lê Huy Phong
insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('Triển khai phần mềm diệt virus cho các máy tính', 'Trong bối cảnh tình trạng virus máy tính lây lan rất mạnh trong mạng nội bộ của công ty, tổng công ty đề nghị chi nhánh Hà Nội tổ chức diệt virus tại các máy tính cá nhân. Thời gian thực hiện trước 1/6/2024', 1,'2','12002', '1', '120', '130', CURRENT_DATE)

--Ông Lê Huy Phong là giám đốc chi nhánh Hà Nội vào duyệt văn bản do ông Nguyễn Văn Hạnh trình lên
update document_out set user_checker = '12001', status = '2'
where doc_id = 1

--Nhân viên văn thư Trần Huy Tuấn của chi nhánh Hà Nội vào phát hành văn bản đi đã được giám đốc ký
update document_out set user_id = '12003', status = '4'
where doc_id = 1

insert into document_in(doc_name, doc_content, textbook_id, doc_type, user_id, status, org_sender, org_receiver, date_in)
values
('Triển khai phần mềm diệt virus cho các máy tính', 'Trong bối cảnh tình trạng virus máy tính lây lan rất mạnh trong mạng nội bộ của công ty, tổng công ty đề nghị chi nhánh Hà Nội tổ chức diệt virus tại các máy tính cá nhân. Thời gian thực hiện trước 1/6/2024', 5,'2','13003', '1', '120', '130', CURRENT_DATE)

--Nhân viên văn thư của chi nhánh TPHCM (Trương Ngọc Khánh) thực hiện chuyển văn bản cho lãnh đạo đơn vị
update document_in set user_checker = '13001', status = '2'
where doc_id = 1

--Lãnh đạo chi nhánh TPHCM (Trần Huy Liệu) vào phân giao văn bản này cho nhân viên Lê Hồng Anh
update document_in set user_maker = '13002', status = '3'
where doc_id = 1

--Nhân viên Lê Hồng Anh vào xử lý văn bản trên
update document_in set status = '4'
where doc_id = 1

--Liệt kê danh sách các văn bản bị lãnh đạo chi nhánh từ chối phê duyệt
select a.doc_name, a.date_out, b.username, c.org_name from document_out a, users b, organization c
where a. user_checker=b.user_id and c.org_id = a.org_sender
and a.status= '3' 

-- trigger tự động tạo mới một văn bản đến vào bảng document_in mỗi khi có sự kiện nhân viên văn thư phát hành văn bản đi
-- thông qua câu lệnh update bảng document_out với status = 4

CREATE OR REPLACE FUNCTION insert_into_document_in()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = '4' THEN
        INSERT INTO document_in(doc_name, doc_content, textbook_id, doc_type, user_id, status, org_sender, org_receiver, date_in)
        SELECT 
            doc_name, 
            doc_content, 
            textbook_id, 
            doc_type, 
            '13003',  -- user_id của nhân viên văn thư Trần Huy Tuấn
            '1',      -- status mặc định
            org_sender,    -- org_sender mặc định
            org_receiver,     -- org_receiver mặc định
            CURRENT_DATE
        FROM document_out
        WHERE doc_id = NEW.doc_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert_document_in
AFTER UPDATE ON document_out
FOR EACH ROW
WHEN (NEW.status = '4')
EXECUTE FUNCTION insert_into_document_in();

insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('Nền kinh tế Việt Nam', 'Tại Việt Nam, tình trạng virus máy tính lây lan rất mạnh trong mạng nội bộ của công ty, tổng công ty đề nghị chi nhánh Hà Nội tổ chức diệt virus tại các máy tính cá nhân. Thời gian thực hiện trước 1/6/2024', 1,'2','13002','1','130','310', CURRENT_DATE);

-- Funtion thêm văn bản đi vào bảng document out với các tham số được truyền vào là: Tên văn bản, nội dung văn bản, user soạn thảo, độ khẩn, trạng thái
-- văn bản, mã chi nhánh gửi, mã chi nhánh nhận

CREATE OR REPLACE FUNCTION insert_into_document_out(
    p_doc_name VARCHAR,
    p_doc_content TEXT,
    p_doc_type VARCHAR,
    p_user_id VARCHAR,
    p_status VARCHAR,
    p_org_sender VARCHAR,
    p_org_receiver VARCHAR,
    p_date_out DATE
)
RETURNS VOID AS $$
DECLARE
    v_textbook_id INTEGER;
BEGIN
    -- Tìm textbook_id từ bảng textbook với org_id = org_sender
    SELECT textbook_id INTO v_textbook_id
    FROM textbook
    WHERE org_id = p_org_sender
    LIMIT 1;
    
    -- Chèn dữ liệu vào bảng document_out
    INSERT INTO document_out (
        doc_name, doc_content, textbook_id, doc_type, user_id, status, org_sender, org_receiver, date_out
    ) VALUES (
        p_doc_name, p_doc_content, v_textbook_id, p_doc_type, p_user_id, p_status, p_org_sender, p_org_receiver, p_date_out
    );
END;
$$ LANGUAGE plpgsql;

--Gọi hàm insert_into_document_out như dưới đây:
select insert_into_document_out(
	'Stability analysis for linear singular systems', 
	'The stability of arbitrarily switched discrete-time linear singular (SDLS) systems is studied. Our analysis builds on the recently introduced one-step-map for SDLS systems of index-1. We first provide a sufficient stability condition in terms of Lyapunov functions. Furthermore, we generalize the notion of joint spectral radius of a finite set of matrix pairs, which allows us to fully characterize exponential stability.',
	'1', 
	'21001', 
	'1', 
	'210', 
	'310',
    CURRENT_DATE
) 

-- Câu lệnh index để tăng tốc độ truy xuất dữ liệu từ bảng document_in và document_out
create index doc_num on document_out (doc_id);
create index doc_num_in on document_in (doc_id);

/* Phạm Thái Sơn */
-- Nhân viên Nguyễn Văn Hạnh thêm mới 1 văn bản đi tại chi nhánh Hà Nội gửi chi nhánh TPHCM với kiểu văn bản thường. Văn bản này
-- được trình lên giám đốc đơn vị là ông Lê Huy Phong
insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('Natural language interface construction',
 'A study on constructing a natural language interface to relational databases, which accepts natural language questions as inputs and generates textual responses.',
 1, '1', '12002', '1', '120', '130', CURRENT_DATE);
 
--Ông Lê Huy Phong là giám đốc chi nhánh Hà Nội vào duyệt văn bản do ông Nguyễn Văn Hạnh trình lên
update document_out set user_checker = '12001', status = '2'
where doc_id = 5;

--Nhân viên văn thư Trần Huy Tuấn của chi nhánh Hà Nội vào phát hành văn bản đi đã được giám đốc ký
update document_out set user_id = '12003', status = '4'
where doc_id = 5;

--Văn bản được chuyển tới chi nhánh TPHCM
insert into document_in(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_in)
values
('Natural language interface construction',
 'A study on constructing a natural language interface to relational databases, which accepts natural language questions as inputs and generates textual responses.',
 5, '2', '13003', '1', '120', '130', CURRENT_DATE);

--Nhân viên văn thư của chi nhánh TPHCM (Trương Ngọc Khánh) thực hiện chuyển văn bản cho lãnh đạo đơn vị
update document_in set user_checker = '13001', status = '2'
where doc_id = 5;

--Lãnh đạo chi nhánh TPHCM (Trần Huy Liệu) vào phân giao văn bản này cho nhân viên Lê Hồng Anh
update document_in set user_maker = '13002', status = '3'
where doc_id = 5;

--Nhân viên Lê Hồng Anh vào xử lý văn bản trên
update document_in set status = '4'
where doc_id = 5;

----2)
-- Nhân viên Nguyễn Anh Đức thêm mới 1 văn bản đi tại chi nhánh Đà Nẵng gửi chi nhánh Cần Thơ với kiểu văn bản khẩn. Văn bản này
-- được trình lên giám đốc đơn vị là ông Lại Thanh Đức
insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('A metaheuristic for the delivery man',
 'The Delivery Man Problem with Time Windows (DMPTW) is an extension of the Delivery Man Problem.',
 7, '2', '21002', '1', '210', '310', CURRENT_DATE);
 
--Ông Lại Thanh Đức là giám đốc chi nhánh Đà Nẵng từ chối duyệt văn bản do ông Nguyễn Anh Đức trình lên
update document_out set user_checker = '21001', status = '3'
where doc_id = 6;

--Liệt kê danh sách các văn bản chưa được phê duyệt
select a.doc_name, a.date_out, b.username, c.org_name from document_out a, users b, organization c
where a. user_maker=b.user_id and c.org_id = a.org_sender
and a.status= '1' 

--Lưu văn bản đi
CREATE OR REPLACE FUNCTION save_document_out(
    p_doc_name VARCHAR(50),
    p_doc_content TEXT,
    p_textbook_id INT,
    p_user_maker VARCHAR(5),
    p_org_sender VARCHAR(3),
    p_org_receive VARCHAR(3),
    p_doc_type VARCHAR(1)
) RETURNS INT AS
$$
BEGIN
    INSERT INTO document_out(doc_name, doc_content, textbook_id, user_maker, org_sender, org_receive, doc_type, status, date_out)
    VALUES (p_doc_name, p_doc_content, p_textbook_id, p_user_maker, p_org_sender, p_org_receive,  p_doc_type, '0', CURRENT_DATE);
   return 1;

    EXCEPTION
        WHEN others THEN
			raise;
           return 0;
END;
$$ LANGUAGE plpgsql;

-- Phê duyệt văn bản
CREATE OR REPLACE FUNCTION send_approval(p_doc_id bigINT) RETURNS INT AS
$$
DECLARE
    affected_rows INT;
BEGIN
   
    UPDATE document_out
    SET status = '2' 
    WHERE doc_id = p_doc_id;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    

    RETURN affected_rows;
    
    EXCEPTION
        WHEN OTHERS THEN

            RETURN -1;
END;
$$ LANGUAGE plpgsql;

--Đã ban hành văn bản
CREATE OR REPLACE FUNCTION send_approved(p_doc_id bigINT,   p_user_checker VARCHAR(5) ) RETURNS INT AS
$$
DECLARE
    affected_rows INT;
BEGIN
   
    UPDATE document_out
    SET status = '4' , user_checker = p_user_checker
    WHERE doc_id = p_doc_id;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    

    RETURN affected_rows;
    
    EXCEPTION
        WHEN OTHERS THEN

            RETURN -1;
END;
$$ LANGUAGE plpgsql;

--Từ chối phê duyệt
CREATE OR REPLACE FUNCTION send_rejected(p_doc_id bigINT,   p_user_checker VARCHAR(5)) RETURNS INT AS
$$
DECLARE
    affected_rows INT;
BEGIN
   
    UPDATE document_out
    SET status = '3'  , user_checker = p_user_checker
    WHERE doc_id = p_doc_id;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    

    RETURN affected_rows;
    
    EXCEPTION
        WHEN OTHERS THEN

            RETURN -1;
END;
$$ LANGUAGE plpgsql;

/*Đào Ngọc Quang*/
-- Nhân viên Nguyễn Anh Đức thêm mới 1 văn bản đi tại chi nhánh Đà Nẵng gửi chi nhánh Hà Nội với kiểu văn bản thường. 
-- Văn bản này được trình lên giám đốc đơn vị là ông Lê Huy Phong
insert into document_out(doc_name, doc_content, textbook_id, doc_type, user_maker, status, org_sender, org_receiver, date_out)
values
('Báo cáo tình hình kinh doanh quý II năm 2024', 'Chi nhánh Đà Nẵng gửi báo cáo tình hình kinh doanh quý II năm 2024. Trong bối cảnh thị trường có nhiều thay đổi, chi nhánh Đà Nẵng đã tiến hành các biện pháp để duy trì sự ổn định và đã đạt được các kết quả nhất định.',
1, '2', '21002', '2', '210', '120', CURRENT_DATE);

-- Ông Lê Huy Phong là giám đốc chi nhánh Hà Nội vào duyệt và từ chối văn bản do ông Nguyễn Anh Đức trình lên
update document_out set user_checker = '12001', status = '3'
where doc_id = 2;

-- Nhân viên văn thư Nguyễn Thu Hà của chi nhánh Cần Thơ vào phát hành văn bản đi chờ giám đốc ký
update document_out set user_id = '31003', status = '1'
where doc_id = 3;

-- trigger tự động tạo mới một văn bản đến vào bảng document_in mỗi khi có sự kiện từ chối phê duyệt văn bản
-- thông qua câu lệnh update bảng document_out với status = 3
-- Trigger function tạo mới văn bản đến vào bảng document_in
CREATE OR REPLACE FUNCTION return_to_sender_document_in()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = '3' THEN
        INSERT INTO document_in(doc_name, doc_content, textbook_id, doc_type, status, org_sender, org_receiver)
        VALUES (
            NEW.doc_name, 
            NEW.doc_content, 
            '2', 
            NEW.doc_type, 
            '1',      -- status mặc định
            NEW.org_receiver,    -- org_receiver của văn bản đi trở thành org_sender mới
            NEW.org_sender       -- org_sender của văn bản đi trở thành org_receiver mới
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger kích hoạt trigger function sau mỗi sự kiện update bảng document_out với status = '3'
CREATE TRIGGER trigger_return_to_sender_document_in
AFTER UPDATE ON document_out
FOR EACH ROW
WHEN (NEW.status = '3')
EXECUTE FUNCTION return_to_sender_document_in();

-- Nhân viên văn thư Trần Huy Tuấn của chi nhánh Hà Nội nhận văn bản từ chi nhánh Đà Nẵng
insert into document_in(doc_name, doc_content, textbook_id, doc_type, user_id, status, org_sender, org_receiver)
values
('Báo cáo tình hình kinh doanh quý II năm 2024', 'Chi nhánh Đà Nẵng gửi báo cáo tình hình kinh doanh quý II năm 2024. Trong bối cảnh thị trường có nhiều thay đổi, chi nhánh Đà Nẵng đã tiến hành các biện pháp để duy trì sự ổn định và đã đạt được các kết quả nhất định.', 2, '1', '12003', '1', '210', '120');

-- Nhân viên văn thư của chi nhánh Hà Nội thực hiện chuyển văn bản cho lãnh đạo đơn vị
update document_in set user_checker = '12001', status = '2'
where doc_id = 1;

-- Giám đốc đơn vị Hồ Chí Minh Trần Huy Liệu đã giao đến nhân viên Lê Hồng Anh để xử lý
update document_in set user_checker = '13001', user_maker = '13002', status = '3'
where doc_id = 4;

-- Nhân viên Lê Hồng Anh vào xử lý văn bản trên
update document_in set status = '4'
where doc_id = 1;

--Liệt kê danh sách các văn bản đã được ban hành bởi văn thư và tên của văn thư tương ứng
select a.doc_name, a.date_out, b.username, c.org_name from document_out a, users b, organization c
where a. user_maker=b.user_id and c.org_id = a.org_sender
and a.status= '1' 

--Hàm đếm số văn bản trong bảng document_in
CREATE OR REPLACE FUNCTION count_documents_in()
RETURNS TABLE (
    doc_type varchar(1),
    status varchar(1),
    count integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(d.doc_type, 'N/A') AS doc_type, 
        COALESCE(d.status, 'N/A') AS status, 
        CAST(COUNT(*) AS integer) AS count
    FROM 
        document_in d
    GROUP BY 
        COALESCE(d.doc_type, 'N/A'), COALESCE(d.status, 'N/A')
    ORDER BY 
        COALESCE(d.doc_type, 'N/A'), COALESCE(d.status, 'N/A');
END;
$$ LANGUAGE plpgsql;

--Hàm đếm số văn bản trong bảng document_out
CREATE OR REPLACE FUNCTION count_documents_out()
RETURNS TABLE (
    doc_type varchar(1),
    status varchar(1),
    count integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(d.doc_type, 'N/A') AS doc_type, 
        COALESCE(d.status, 'N/A') AS status, 
        CAST(COUNT(*) AS integer) AS count
    FROM 
        document_out d
    GROUP BY 
        COALESCE(d.doc_type, 'N/A'), COALESCE(d.status, 'N/A')
    ORDER BY 
        COALESCE(d.doc_type, 'N/A'), COALESCE(d.status, 'N/A');
END;
$$ LANGUAGE plpgsql;

-- Đếm số văn bản trong bảng document_in
SELECT * FROM count_documents_in();

-- Đếm số văn bản trong bảng document_out
SELECT * FROM count_documents_out();