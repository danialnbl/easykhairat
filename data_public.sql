--
-- PostgreSQL database dump
--

\restrict PKd97ECe0FMbSfgYPmiSQTg48jFE04zhSs86Bs8hGDLEeXccqNRrNwp88LfjDCW

-- Dumped from database version 15.8
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_name, user_identification, user_phone_no, user_address, user_email, user_type, user_password, user_created_at, user_updated_at, user_id) FROM stdin;
Haji Yusof bin Omar	690101011801	01123138061	167, Lorong TS 6, Taman Sepakat, 25150 Kuantan, Pahang	danialnabil456@gmail.com	admin	danial15	2023-03-05 10:28:49.586034+00	2025-06-16 05:08:36.946044	7e3530c6-596a-4d40-8da4-c70c0280fee2
Khairul Irfan bin Kamarul	900912016845	01205648624	150, Lorong TS 6, Taman Sepakat, 25150 Kuantan, Pahang	siunta0208@gmail.com	user	Unknown	2025-06-16 05:11:19.413932+00	2025-06-16 05:11:19.413932	242c9bfb-cd10-458c-8e55-efa1408c7398
Mohamad Amirul bin Saidi	912508010145	01145467896	155, Lorong TS 6, Taman Sepakat, 25150 Kuantan, Pahang	nurighost@gmail.com	user	Unknown	2025-06-16 05:24:20.989844+00	2025-06-16 05:24:20.989844	83d8ccc5-5dd1-4d11-ab7d-8ce3f07cddb4
Iqram bin Mohd Rafie	021025010252	01344538061	173, Lorong TS 6, Taman Sepakat, 25150 Kuantan, Pahang	ghostsikodok@gmail.com	user	Unknown	2025-05-13 17:53:28.76204+00	2025-06-16 05:06:34.800774	0aca75ee-7b42-44fb-8b50-16d4ac6584ff
Mohamad Danial Nabil	020825010181	01123138062	172, Lorong TS 6, Taman Sepakat, 25150 Kuantan, Pahang	danialnabil0208@gmail.com	user	danial15	2023-03-01 14:54:04.260508+00	2025-06-16 05:06:54.688302	8a1b120c-c4a7-448b-9f78-047b5080eb1d
Muhammad Daniel Firdaus	020708121069	0128860725	Blok B, perumahan kuaters forest, sfd, FKB/G/1, 90000, Sandakan , Sabah	mohddaniel375@gmail.com	admin	Unknown	2026-05-04 05:01:06.130703+00	2026-05-04 06:19:11.547036	cd17b5a0-097c-4968-bd4a-9ef61107296f
daniel firdaus	020708121069	0128860725	sandakan, sabah	dannyzzz07@gmail.com	user	Unknown	2026-05-04 13:14:24.557639+00	2026-05-04 13:14:24.557639	f2333afa-933c-4c90-b971-1d7518470344
\.


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin (admin_id, admin_role, user_id) FROM stdin;
1	admin	7e3530c6-596a-4d40-8da4-c70c0280fee2
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcements (announcement_id, announcement_title, announcement_description, announcement_type, announcement_created_at, announcement_updated_at, admin_id, announcement_image) FROM stdin;
5	Muhammad Adam Bin Mohd Nazim	Dukacita dimaklumkan bahawa mahasiswa yang bernama Muhammad Adam Bin Mohd Nazim telah kembali ke rahmatullah. Marilah kita bersama-sama sedekahkan bacaan Al-Fatihah kepada arwah semoga rohnya dicucuri rahmat dan ditempatkan dalam kalangan orang beriman.	Kematian	2025-05-18 15:35:14.706+00	2025-06-13 16:20:10.854708	1	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/announcement/1749831553904_contohKematian.png
4	Selamat Datang Ke Easykhairat	sistem khairat kematian masjid permatang badak	Umum	2025-05-17 23:52:01.695+00	2025-06-13 16:22:57.72432	1	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/announcement/1749831760183_Welcome.jpg
6	Mohamad Syafiq Bin Ali	Dukacita dimaklumkan bahawa bekas Mantan Yang Di-Pertua Majlis Perwakilan Pelajar UMPSA Sesi 2014/2015 yang bernama Mohamad Syafiq Bin Ali telah kembali ke rahmatullah. Marilah kita bersama-sama sedekahkan bacaan Al-Fatihah kepada arwah semoga rohnya dicucuri rahmat dan ditempatkan dalam kalangan orang beriman.	Kematian	2025-06-16 13:32:33.555+00	2025-06-16 13:32:33.555	1	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/announcement/1750051951975_contohKematian2.png
8	KULIAH MAGHRIB - HADIS & TAFSIR	KULIAH MAGHRIB\nMURABBI : USTAZ ABD GHANI (MBR)\nTAJUK : HADIS & TAFSIR\n📆 - ISNIN / 16 JUN 2025 bersamaan\n19 ZULHIJJAH 1446 H\n⏰ - Selepas MAGHRIB	Umum	2025-06-16 20:00:55.371+00	2025-06-16 20:00:55.371	1	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/announcement/1750075251670_kuliah2.jpg
7	KULIAH MAGHRIB - KISAH PARA NABI	KULIAH MAGHRIB\nMURABBI : USTAZ FAKHZAN ZULKAWI\nTAJUK : KISAH PARA NABI\n📆 - AHAD / 15 JUN  2025  bersamaan\n18 ZULHIJJAH 1446 H\n⏰ - Selepas MAGHRIB	Umum	2025-06-16 13:37:27.091+00	2025-06-16 12:01:07.632653	1	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/announcement/1750052243721_kuliah.jpg
\.


--
-- Data for Name: family; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.family (family_id, familymember_name, familymember_identification, familymember_relationship, family_created_at, family_updated_at, user_id) FROM stdin;
6	Danial Nabil	020825010181	Abang	2025-06-07 03:43:34.139896+00	2025-06-07 03:43:34.139898	8a1b120c-c4a7-448b-9f78-047b5080eb1d
\.


--
-- Data for Name: claims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.claims (claim_id, "claim_overallStatus", claim_created_at, claim_updated_at, family_id, user_id, claim_type, claim_reason, claim_certificate_url) FROM stdin;
22	Lulus	2025-05-16 20:45:06.376094+00	2025-06-16 12:48:06.391889	\N	242c9bfb-cd10-458c-8e55-efa1408c7398	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1750077905721.jpg
25	Dalam Proses	2025-06-17 16:35:48.835749+00	2025-06-17 16:35:48.835812	\N	8a1b120c-c4a7-448b-9f78-047b5080eb1d	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1750149348425.jpg
24	Lulus	2025-06-17 16:23:44.250777+00	2025-09-20 13:26:19.68283	\N	83d8ccc5-5dd1-4d11-ab7d-8ce3f07cddb4	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1750148623537.jpg
28	Dibatalkan	2025-08-26 00:03:53.288082+00	2025-09-25 20:21:21.198492	\N	8a1b120c-c4a7-448b-9f78-047b5080eb1d	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1756181032926.jpg
20	Lulus	2023-06-16 14:10:29.935026+00	2025-10-21 08:15:59.825666	\N	8a1b120c-c4a7-448b-9f78-047b5080eb1d	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1750054229285.jpg
29	Lulus	2026-05-04 20:52:14.557087+00	2026-05-04 12:53:35.778211	\N	8a1b120c-c4a7-448b-9f78-047b5080eb1d	Ahli Sendiri	\N	https://djeeipnokclsjabwadoq.supabase.co/storage/v1/object/public/certificates/certificates/temp_1777899134188.jpg
\.


--
-- Data for Name: claim_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.claim_line ("claimLine_id", "claimLine_reason", "claimLine_totalPrice", "claimLine_created_at", claimline_updated_at, claim_id) FROM stdin;
30	Kos Gali	50	2025-06-16 20:45:31.077368+00	2025-06-16 20:45:31.07737	22
27	Mandi jenazah	100	2023-06-16 14:31:41.783+00	2025-06-16 13:49:09.859671	20
33	Jos Gali	50	2025-06-17 16:23:53.944497+00	2025-06-17 16:23:53.944499	24
34	Kos Van	100	2025-06-17 16:24:19.105208+00	2025-06-17 16:24:19.105214	24
35	Kos Gali	50	2025-06-17 16:35:58.363173+00	2025-06-17 16:35:58.363176	25
36	Kos Van	100	2025-06-17 16:36:04.570284+00	2025-06-17 16:36:04.570286	25
26	Van + Pemandu	100	2023-06-16 14:31:29.501+00	2025-10-27 09:23:11.50661	20
\.


--
-- Data for Name: fees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fees (fee_id, fee_description, fee_due, fee_type, fee_created_at, fee_updated_at, admin_id, fee_amount) FROM stdin;
8	Yuran Tahunan 2023	2023-08-16	Yuran Tahunan	2023-05-07 00:49:00.858+00	2025-06-16 07:02:16.0056	1	50
2	Yuran Tahunan 2024	2024-08-16	Yuran Tahunan	2024-04-30 06:28:36.670518+00	2025-06-16 07:02:29.327248	1	50
10	Yuran Tahunan 2025	2025-08-16	Tahunan	2025-06-16 15:19:24.197+00	2025-06-16 15:19:24.197	1	50
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (payment_id, payment_value, payment_description, payment_created_at, payment_updated_at, fee_id, user_id, payment_type, reference_id) FROM stdin;
156	50	Yuran Tahunan 2024	2024-04-16 15:23:40.675+00	2025-06-16 11:56:14.45858	2	242c9bfb-cd10-458c-8e55-efa1408c7398	Tunai	\N
161	50	Yuran Tahunan 2023	2025-06-17 14:14:07.699+00	2025-06-17 14:14:07.699	8	83d8ccc5-5dd1-4d11-ab7d-8ce3f07cddb4	Tunai	\N
162	50	Payment for Yuran Tahunan 2024	2025-06-17 14:15:36.749256+00	2025-06-17 14:15:36.749257	2	83d8ccc5-5dd1-4d11-ab7d-8ce3f07cddb4	FPX	5uzym4x4
163	50	Yuran Tahunan 2023	2025-06-17 16:18:02.203+00	2025-06-17 16:18:02.203	8	0aca75ee-7b42-44fb-8b50-16d4ac6584ff	Tunai	\N
164	50	Payment for Yuran Tahunan 2025	2025-06-17 16:23:03.41735+00	2025-06-17 16:23:03.417351	10	83d8ccc5-5dd1-4d11-ab7d-8ce3f07cddb4	FPX	h6oic3fw
165	50	Yuran Tahunan 2024	2025-06-17 16:31:50.038+00	2025-06-17 16:31:50.038	2	0aca75ee-7b42-44fb-8b50-16d4ac6584ff	Tunai	\N
160	50	Payment for Yuran Tahunan 2025	2025-06-16 16:23:44.407059+00	2025-06-16 16:23:44.40706	10	242c9bfb-cd10-458c-8e55-efa1408c7398	FPX	kjgcurdv
155	50	Yuran Tahunan 2023	2023-05-16 15:23:17.712+00	2025-06-16 11:56:02.429108	8	242c9bfb-cd10-458c-8e55-efa1408c7398	Tunai	\N
168	50	Yuran Tahunan 2025	2025-07-23 11:10:58.994+00	2025-07-23 11:10:58.994	10	0aca75ee-7b42-44fb-8b50-16d4ac6584ff	Tunai	\N
170	50	Payment for Yuran Tahunan 2023	2025-12-24 09:20:08.061618+00	2025-12-24 09:20:08.061619	8	8a1b120c-c4a7-448b-9f78-047b5080eb1d	FPX	vai0rynw
\.


--
-- Name: admin_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_admin_id_seq', 1, true);


--
-- Name: announcements_announcement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.announcements_announcement_id_seq', 8, true);


--
-- Name: claim_claim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.claim_claim_id_seq', 29, true);


--
-- Name: claim_line_claimLine_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."claim_line_claimLine_id_seq"', 40, true);


--
-- Name: family_family_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.family_family_id_seq', 6, true);


--
-- Name: fee_fee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fee_fee_id_seq', 10, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 180, true);


--
-- PostgreSQL database dump complete
--

\unrestrict PKd97ECe0FMbSfgYPmiSQTg48jFE04zhSs86Bs8hGDLEeXccqNRrNwp88LfjDCW

