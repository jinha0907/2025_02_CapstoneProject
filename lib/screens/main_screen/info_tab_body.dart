// lib/screens/info_tab_body.dart
import 'package:flutter/material.dart';
import 'info_category_screen.dart';
import 'info_page_screen.dart';
import 'info_detail_screen.dart';

enum InfoStep { root, category, page, detail }

class InfoTabBody extends StatefulWidget {
  const InfoTabBody({super.key});

  @override
  State<InfoTabBody> createState() => _InfoTabBodyState();
}

class _InfoTabBodyState extends State<InfoTabBody> {
  InfoStep _step = InfoStep.root;

  // 현재 선택된 데이터들
  String _currentHeaderTitle = '정보 모음';
  String _currentHeaderSubtitle = '퀴즈 정보와 생활 정보 모음집';

  // 카테고리 / 페이지 데이터
  List<String> _categories = [];

  // 페이지 리스트: 백엔드에서 받아온 title/subtitle 목록
  List<String> _pageTitles = [];
  List<String> _pageSubtitles = [];

  // 선택된 값들
  String _selectedCategory = '';
  String _selectedPageTitle = '';
  String _selectedPageSubtitle = '';

  // ------ Root 화면에서 퀴즈 정보 모음 클릭 ------
  void _onQuizRootTap() {
    setState(() {
      _step = InfoStep.category;
      _currentHeaderTitle = '퀴즈 정보 모음';
      _currentHeaderSubtitle = '퀴즈 관련 정보 모음집';

      // TODO: 여기도 나중에 백엔드에서 카테고리 목록을 받아오도록 변경 가능
      _categories = [
        '한국 역사 퀴즈',
        '한국 음식 퀴즈',
        '한국 예절 퀴즈',
      ];
    });
  }

  // ------ Root 화면에서 생활 정보 모음 클릭 ------
  void _onLifeRootTap() {
    setState(() {
      _step = InfoStep.category;
      _currentHeaderTitle = '생활 정보 모음';
      _currentHeaderSubtitle = '한국 생활에 필수적인 정보 모음집';

      // TODO: 백엔드 카테고리 목록으로 교체 가능
      _categories = [
        '한국의 일상생활',
        '한국의 인사 예절',
        '한국의 직장 생활',
      ];
    });
  }

  // ------ 카테고리에서 특정 카테고리 클릭 ------
  void _onCategoryTap(int index, String category) async {
    // 여기서 백엔드로부터 "title 목록"과 "subtitle 목록"을 받아온다고 가정
    // 실제 코드에서는 아래 TODO 부분을 http/dio 등으로 교체하면 됨.
    //
    // final response = await api.getInfoPageList(category: category);
    // final titlesFromApi = response.titles;        // List<String>
    // final subtitlesFromApi = response.subtitles;  // List<String>

    // 데모용 더미 데이터
    final titlesFromApi = <String>[
      '한국 문화 생활 정보 01',
      '한국 문화 생활 정보 02',
      '한국 문화 생활 정보 03',
      '한국 문화 생활 정보 04',
    ];
    final subtitlesFromApi = <String>[
      '할인 행사(1+1, 2+1) 활용하기',
      '대중교통 카드 사용법',
      '배달 문화 이해하기',
      '편의점 이용 팁',
    ];

    setState(() {
      _selectedCategory = category;
      _pageTitles = titlesFromApi;
      _pageSubtitles = subtitlesFromApi;
      _step = InfoStep.page;
    });
  }

  // ------ 페이지 리스트에서 특정 페이지 클릭 ------
  void _onPageTap(int index, String pageTitle, String pageSubtitle) {
    setState(() {
      _selectedPageTitle = pageTitle;
      _selectedPageSubtitle = pageSubtitle;
      _step = InfoStep.detail;
    });
  }

  // ------ 디테일 내용 백엔드에서 불러오기 ------
  Future<String> _loadDetailContent(
      String category,
      String title,
      String subtitle,
      ) async {
    // TODO: 여기에 실제 백엔드 API 호출 넣기
    //
    // final response = await api.getInfoDetail(
    //   category: category,
    //   title: title,
    //   subtitle: subtitle,
    // );
    // return response.content;

    // 데모용 더미 구현
    await Future.delayed(const Duration(milliseconds: 300));
    return
      '[$category]\n$title\n($subtitle)\n\n'
          '여기에 백엔드에서 받아온 상세 내용을 표시합니다.\n'
          '실제 구현에서는 위의 TODO 부분에서 API를 호출해서\n'
          'response.content 같은 값을 리턴하도록 바꾸면 됩니다.';
  }

  // ------ “단계별 뒤로가기” ------
  void _goBackStep() {
    setState(() {
      if (_step == InfoStep.detail) {
        _step = InfoStep.page;
      } else if (_step == InfoStep.page) {
        _step = InfoStep.category;
      } else if (_step == InfoStep.category) {
        _step = InfoStep.root;
        _currentHeaderTitle = '정보 모음';
        _currentHeaderSubtitle = '퀴즈 정보와 생활 정보 모음집';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8E3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _buildStepContent(),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case InfoStep.root:
        return _buildRoot();
      case InfoStep.category:
        return InfoCategoryScreen(
          headerTitle: _currentHeaderTitle,
          headerSubtitle: _currentHeaderSubtitle,
          categories: _categories,
          onCategoryTap: _onCategoryTap,
          onBack: _goBackStep,
        );
      case InfoStep.page:
        return InfoPageScreen(
          categoryTitle: _selectedCategory,
          titles: _pageTitles,
          subtitles: _pageSubtitles,
          onPageTap: _onPageTap,
          onBack: _goBackStep,
        );
      case InfoStep.detail:
        return InfoDetailScreen(
          categoryTitle: _selectedCategory,
          pageTitle: _selectedPageTitle,
          pageSubtitle: _selectedPageSubtitle, // ★ 여기로 subtitle 전달
          loadDetail: _loadDetailContent,      // ★ 실제 본문은 여기서 로드
          onBack: _goBackStep,
        );
    }
  }

  // ----- Root 화면: 퀴즈 정보 모음 / 생활 정보 모음 -----
  Widget _buildRoot() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderArea(),
          const SizedBox(height: 32),

          _InfoEntryCard(
            text: '퀴즈 정보 모음',
            onTap: _onQuizRootTap,
          ),
          const SizedBox(height: 20),

          _InfoEntryCard(
            text: '생활 정보 모음',
            onTap: _onLifeRootTap,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 상단 캐릭터 + 말풍선 (Root 전용)
class _HeaderArea extends StatelessWidget {
  const _HeaderArea();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 90,
            height: 120,
            child: Image.asset(
              'assets/images/tiger_image.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F6),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '정보 모음',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '퀴즈 정보와 생활 정보 모음집',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF858494),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Root 카드
class _InfoEntryCard extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _InfoEntryCard({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: Color(0xFF4E7C88),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
