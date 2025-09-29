CREATE TABLE Guests (
    guest_id       NUMBER PRIMARY KEY,
    first_name     VARCHAR2(50),
    last_name      VARCHAR2(50),
    email          VARCHAR2(100) UNIQUE,
    phone          VARCHAR2(20),
    nationality    VARCHAR2(50),
    registration_date DATE DEFAULT SYSDATE
);


CREATE TABLE Rooms (
    room_id        NUMBER PRIMARY KEY,
    room_number    VARCHAR2(10) UNIQUE,
    room_type      VARCHAR2(30),   -- e.g., Single, Double, Suite
    price_per_night NUMBER(10,2),
    status         VARCHAR2(20)    -- e.g., Available, Occupied, Maintenance
);

CREATE TABLE Bookings (
    booking_id     NUMBER PRIMARY KEY,
    guest_id       NUMBER NOT NULL,
    room_id        NUMBER NOT NULL,
    checkin_date   DATE NOT NULL,
    checkout_date  DATE NOT NULL,
    booking_date   DATE DEFAULT SYSDATE,
    status         VARCHAR2(20),   -- e.g., Confirmed, Checked-in, Cancelled
    
    CONSTRAINT fk_guest FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);



CREATE TABLE Payments (
    payment_id     NUMBER PRIMARY KEY,
    booking_id     NUMBER NOT NULL,
    amount_paid    NUMBER(10,2),
    payment_date   DATE DEFAULT SYSDATE,
    payment_method VARCHAR2(20),   -- e.g., Cash, Card, MobileMoney
    
    CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);



INSERT INTO Guests (guest_id, first_name, last_name, email, phone, nationality, registration_date) VALUES
(1, 'Jean', 'Niyonzima', 'jean.niyonzima@example.com', '+250788111111', 'Rwanda', DATE '2025-01-10'),
(2, 'Alice', 'Mukamana', 'alice.mukamana@example.com', '+250788222222', 'Rwanda', DATE '2025-01-15'),
(3, 'David', 'Smith', 'david.smith@example.com', '+447700900123', 'UK', DATE '2025-01-20'),
(4, 'Claudine', 'Uwase', 'claudine.uwase@example.com', '+250788333333', 'Rwanda', DATE '2025-02-01'),
(5, 'Maria', 'Lopez', 'maria.lopez@example.com', '+349100200300', 'Spain', DATE '2025-02-05'),
(6, 'Peter', 'Johnson', 'peter.johnson@example.com', '+14085551234', 'USA', DATE '2025-02-10'),
(7, 'Aline', 'Ingabire', 'aline.ingabire@example.com', '+250788444444', 'Rwanda', DATE '2025-02-15'),
(8, 'John', 'Mugenzi', 'john.mugenzi@example.com', '+250788555555', 'Rwanda', DATE '2025-02-20'),
(9, 'Sarah', 'Brown', 'sarah.brown@example.com', '+447700900555', 'UK', DATE '2025-03-01'),
(10, 'Eric', 'Kamanzi', 'eric.kamanzi@example.com', '+250788666666', 'Rwanda', DATE '2025-03-05');



INSERT INTO Rooms (room_id, room_number, room_type, price_per_night, status) VALUES
(1, '101', 'Single', 20000, 'Available'),
(2, '102', 'Single', 20000, 'Available'),
(3, '201', 'Double', 35000, 'Available'),
(4, '202', 'Double', 35000, 'Available'),
(5, '301', 'Suite', 60000, 'Available'),
(6, '302', 'Suite', 60000, 'Available'),
(7, '401', 'Single', 20000, 'Maintenance'),
(8, '402', 'Double', 35000, 'Available'),
(9, '501', 'Suite', 60000, 'Available'),
(10, '502', 'Double', 35000, 'Available');



INSERT INTO Bookings (booking_id, guest_id, room_id, checkin_date, checkout_date, booking_date, status) VALUES
(1, 1, 1, DATE '2025-01-12', DATE '2025-01-14', DATE '2025-01-10', 'Checked-out'),
(2, 2, 3, DATE '2025-01-16', DATE '2025-01-18', DATE '2025-01-15', 'Checked-out'),
(3, 3, 5, DATE '2025-01-25', DATE '2025-01-30', DATE '2025-01-20', 'Checked-out'),
(4, 4, 2, DATE '2025-02-03', DATE '2025-02-05', DATE '2025-02-01', 'Checked-out'),
(5, 5, 6, DATE '2025-02-07', DATE '2025-02-12', DATE '2025-02-05', 'Checked-out'),
(6, 6, 4, DATE '2025-02-12', DATE '2025-02-15', DATE '2025-02-10', 'Checked-out'),
(7, 7, 8, DATE '2025-02-16', DATE '2025-02-20', DATE '2025-02-15', 'Checked-out'),
(8, 8, 10, DATE '2025-02-22', DATE '2025-02-25', DATE '2025-02-20', 'Checked-out'),
(9, 9, 9, DATE '2025-03-02', DATE '2025-03-06', DATE '2025-03-01', 'Confirmed'),
(10, 10, 3, DATE '2025-03-06', DATE '2025-03-08', DATE '2025-03-05', 'Confirmed');



INSERT INTO Payments (payment_id, booking_id, amount_paid, payment_date, payment_method) VALUES
(1, 1, 40000, DATE '2025-01-12', 'Cash'),
(2, 2, 70000, DATE '2025-01-16', 'MobileMoney'),
(3, 3, 30000, DATE '2025-01-25', 'Card'),
(4, 3, 30000, DATE '2025-01-28', 'Card'),  -- split payment
(5, 4, 40000, DATE '2025-02-03', 'Cash'),
(6, 5, 60000, DATE '2025-02-07', 'MobileMoney'),
(7, 6, 105000, DATE '2025-02-12', 'Card'),
(8, 7, 140000, DATE '2025-02-16', 'MobileMoney'),
(9, 8, 70000, DATE '2025-02-22', 'Cash'),
(10, 9, 120000, DATE '2025-03-02', 'Card');



SELECT g.guest_id,
       g.first_name || ' ' || g.last_name AS guest_name,
       SUM(p.amount_paid) AS total_spent,
       RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS spending_rank
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
JOIN Payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.first_name, g.last_name;



SELECT p.payment_date,
       SUM(p.amount_paid) AS daily_revenue,
       SUM(SUM(p.amount_paid)) OVER (ORDER BY p.payment_date) AS cumulative_revenue
FROM Payments p
GROUP BY p.payment_date
ORDER BY p.payment_date;



SELECT r.room_type,
       COUNT(b.booking_id) AS total_bookings,
       ROUND(AVG(COUNT(b.booking_id)) OVER (PARTITION BY r.room_type), 2) AS avg_bookings_per_type
FROM Rooms r
LEFT JOIN Bookings b ON r.room_id = b.room_id
GROUP BY r.room_type, b.room_id;



SELECT TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
       SUM(p.amount_paid) AS monthly_revenue,
       LAG(SUM(p.amount_paid)) OVER (ORDER BY TO_CHAR(p.payment_date, 'YYYY-MM')) AS prev_month_revenue,
       SUM(p.amount_paid) - 
       LAG(SUM(p.amount_paid)) OVER (ORDER BY TO_CHAR(p.payment_date, 'YYYY-MM')) AS revenue_change
FROM Payments p
GROUP BY TO_CHAR(p.payment_date, 'YYYY-MM')
ORDER BY month;


SELECT g.guest_id,
       g.first_name || ' ' || g.last_name AS guest_name,
       SUM(p.amount_paid) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(p.amount_paid) DESC) AS spending_quartile
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
JOIN Payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.first_name, g.last_name
ORDER BY spending_quartile, total_spent DESC;
