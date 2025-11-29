import 'package:flutter/material.dart';

import '../../../api/info_api.dart';
import '../../../DTO/culture_info.dart';
import '../../../DTO/life_info.dart';

import 'info_title_screen.dart';
import 'info_subtitle_screen.dart';
import 'info_subsubtitle_screen.dart';
import 'info_detail_screen.dart';

/// 화면 단계
///
/// culture : pickKind → titleList → subtitleList → subsubtitleList → detail
/// life    : pickKind → titleList → subtitleList → detail
enum InfoStep {
  pickKind,
  titleList,
  subtitleList,
  subsubtitleList,
  detail,
}

class InfoTabBody extends StatefulWidget {
  const InfoTabBody({super.key});

  @override
  State<InfoTabBody> createState() => _InfoTabBodyState();
}

class _InfoTabBodyState extends State<InfoTabBody> {
  InfoKind? _kind;
  InfoStep _step = InfoStep.pickKind;

  bool _loading = false;
  String? _errorMessage;

  // 루트 화면 텍스트
  String _rootTitle = '정보 모음';
  String _rootSubtitle = '퀴즈 정보와 생활 정보를 한 곳에서 볼 수 있어요.';

  // 공통 리스트
  List<String> _titles = [];
  List<String> _subtitles = [];
  List<String> _subsubtitles = [];

  // culture / life 전체 데이터
  List<CultureInfo> _cultureInfos = [];
  List<LifeInfo> _lifeInfos = [];

  // 선택 상태
  String? _selectedTitle;
  String? _selectedSubtitle;
  String? _selectedSubsubtitle;

  CultureInfo? _selectedCultureInfo;
  LifeInfo? _selectedLifeInfo;

  // ===========================
  // Kind 선택 (퀴즈 정보 / 생활 정보)
  // ===========================
  void _selectKind(InfoKind kind) {
    setState(() {
      _kind = kind;
      _errorMessage = null;
    });
    _loadTitles();
  }

  // ===========================
  // API 호출
  // ===========================

  Future<void> _loadTitles() async {
    final kind = _kind;
    if (kind == null) return;

    setState(() {
      _step = InfoStep.titleList;
      _loading = true;
      _errorMessage = null;

      _titles = [];
      _subtitles = [];
      _subsubtitles = [];
      _cultureInfos = [];
      _lifeInfos = [];

      _selectedTitle = null;
      _selectedSubtitle = null;
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
      _selectedLifeInfo = null;
    });

    try {
      final titles = await InfoApi.fetchTitles(kind);
      if (!mounted) return;
      setState(() {
        _titles = titles;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '정보를 불러오지 못했어요.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadSubtitles(String title) async {
    final kind = _kind;
    if (kind == null) return;

    setState(() {
      _step = InfoStep.subtitleList;
      _loading = true;
      _errorMessage = null;

      _selectedTitle = title;

      _subtitles = [];
      _subsubtitles = [];
      _cultureInfos = [];
      _lifeInfos = [];

      _selectedSubtitle = null;
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
      _selectedLifeInfo = null;
    });

    try {
      if (kind == InfoKind.culture) {
        final infos = await InfoApi.fetchCultureInfosByTitle(title);
        if (!mounted) return;

        // 같은 title 안에서 subtitle 중복 제거
        final subs = <String>[];
        for (final info in infos) {
          if (!subs.contains(info.subtitle)) {
            subs.add(info.subtitle);
          }
        }

        setState(() {
          _cultureInfos = infos;
          _subtitles = subs;
        });
      } else {
        final infos = await InfoApi.fetchLifeInfosByTitle(title);
        if (!mounted) return;

        final subs = infos.map((e) => e.subtitle).toList();

        setState(() {
          _lifeInfos = infos;
          _subtitles = subs;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '목록을 불러오지 못했어요.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _onSubtitleSelected(int index, String subtitle) {
    final kind = _kind;
    if (kind == null) return;

    setState(() {
      _selectedSubtitle = subtitle;
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
      _selectedLifeInfo = null;
    });

    if (kind == InfoKind.culture) {
      // culture: subtitle → subsubtitle 목록으로
      final subsubs = _cultureInfos
          .where((e) => e.subtitle == subtitle)
          .map((e) => e.subsubtitle)
          .toList();

      setState(() {
        _subsubtitles = subsubs;
        _step = InfoStep.subsubtitleList;
      });
    } else {
      // life: 바로 detail 로 이동
      final info = _lifeInfos[index];
      setState(() {
        _selectedLifeInfo = info;
        _step = InfoStep.detail;
      });
    }
  }

  void _onSubsubtitleSelected(int index, String subsubtitle) {
    final selectedTitle = _selectedTitle;
    final selectedSubtitle = _selectedSubtitle;
    if (selectedTitle == null || selectedSubtitle == null) return;

    final info = _cultureInfos.firstWhere(
          (e) =>
      e.title == selectedTitle &&
          e.subtitle == selectedSubtitle &&
          e.subsubtitle == subsubtitle,
      orElse: () => _cultureInfos[index],
    );

    setState(() {
      _selectedSubsubtitle = subsubtitle;
      _selectedCultureInfo = info;
      _step = InfoStep.detail;
    });
  }

  // ===========================
  // 뒤로 가기
  // ===========================

  void _goBackFromTitleList() {
    setState(() {
      _step = InfoStep.pickKind;

      _titles = [];
      _subtitles = [];
      _subsubtitles = [];
      _cultureInfos = [];
      _lifeInfos = [];

      _selectedTitle = null;
      _selectedSubtitle = null;
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
      _selectedLifeInfo = null;
    });
  }

  void _goBackFromSubtitleList() {
    setState(() {
      _step = InfoStep.titleList;

      _subtitles = [];
      _subsubtitles = [];
      _cultureInfos = [];
      _lifeInfos = [];

      _selectedSubtitle = null;
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
      _selectedLifeInfo = null;
    });
  }

  void _goBackFromSubsubtitleList() {
    setState(() {
      _step = InfoStep.subtitleList;

      _subsubtitles = [];
      _selectedSubsubtitle = null;
      _selectedCultureInfo = null;
    });
  }

  void _goBackFromDetail() {
    final kind = _kind;
    if (kind == InfoKind.culture) {
      setState(() {
        _step = InfoStep.subsubtitleList;
      });
    } else {
      setState(() {
        _step = InfoStep.subtitleList;
      });
    }
  }

  // ===========================
  // 화면 빌더
  // ===========================

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                switch (_step) {
                  case InfoStep.titleList:
                    _loadTitles();
                    break;
                  case InfoStep.subtitleList:
                    if (_selectedTitle != null) {
                      _loadSubtitles(_selectedTitle!);
                    }
                    break;
                  case InfoStep.subsubtitleList:
                  case InfoStep.detail:
                  case InfoStep.pickKind:
                    _goBackFromTitleList();
                    break;
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    switch (_step) {
      case InfoStep.pickKind:
        return _buildPickKind();
      case InfoStep.titleList:
        return _buildTitleList();
      case InfoStep.subtitleList:
        return _buildSubtitleList();
      case InfoStep.subsubtitleList:
        return _buildSubsubtitleList();
      case InfoStep.detail:
        return _buildDetail();
    }
  }

  // root: culture / life 선택 화면
  Widget _buildPickKind() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          _rootTitle,
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _rootSubtitle,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        _RootCard(
          icon: Icons.quiz_outlined,
          title: '퀴즈 정보 모음',
          subtitle: '퀴즈에 등장하는 문화 정보를 모아봤어요.',
          onTap: () => _selectKind(InfoKind.culture),
        ),
        const SizedBox(height: 16),
        _RootCard(
          icon: Icons.home_outlined,
          title: '생활 정보 모음',
          subtitle: '한국 생활에 꼭 필요한 정보를 볼 수 있어요.',
          onTap: () => _selectKind(InfoKind.life),
        ),
      ],
    );
  }

  Widget _buildTitleList() {
    final kind = _kind;
    if (kind == null) return const SizedBox.shrink();

    return InfoTitleScreen(
      headerTitle: kind.label,
      headerSubtitle: kind == InfoKind.culture
          ? '관심 있는 문화 주제를 선택해 보세요.'
          : '관심 있는 생활 정보를 선택해 보세요.',
      titles: _titles,
      onTitleTap: _loadSubtitles,
      onBack: _goBackFromTitleList,
    );
  }

  Widget _buildSubtitleList() {
    final kind = _kind;
    final selectedTitle = _selectedTitle ?? '';
    if (kind == null) return const SizedBox.shrink();

    return InfoSubtitleScreen(
      headerTitle: selectedTitle,
      headerSubtitle: kind == InfoKind.culture
          ? '세부 문화 주제를 선택해 주세요.'
          : '보고 싶은 정보를 선택해 주세요.',
      subtitles: _subtitles,
      onSubtitleTap: _onSubtitleSelected,
      onBack: _goBackFromSubtitleList,
    );
  }

  Widget _buildSubsubtitleList() {
    final selectedSubtitle = _selectedSubtitle ?? '';

    return InfoSubsubtitleScreen(
      headerTitle: selectedSubtitle,
      headerSubtitle: '더 구체적인 내용을 선택해 주세요.',
      subsubtitles: _subsubtitles,
      onSubsubtitleTap: _onSubsubtitleSelected,
      onBack: _goBackFromSubsubtitleList,
    );
  }

  Widget _buildDetail() {
    final kind = _kind;
    if (kind == null) return const SizedBox.shrink();

    if (kind == InfoKind.culture) {
      final info = _selectedCultureInfo;
      if (info == null) return const SizedBox.shrink();

      return InfoDetailScreen(
        headerTitle: kind.label,
        mainTitle: _selectedSubtitle ?? info.subtitle,
        subTitle: _selectedSubsubtitle ?? info.subsubtitle,
        loadDetail: () =>
            InfoApi.fetchDetail(kind: InfoKind.culture, infoId: info.infoId),
        onBack: _goBackFromDetail,
      );
    } else {
      final info = _selectedLifeInfo;
      if (info == null) return const SizedBox.shrink();

      return InfoDetailScreen(
        headerTitle: kind.label,
        mainTitle: _selectedTitle ?? info.title,
        subTitle: info.subtitle,
        loadDetail: () =>
            InfoApi.fetchDetail(kind: InfoKind.life, infoId: info.infoId),
        onBack: _goBackFromDetail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8E3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _buildBody(),
      ),
    );
  }
}

class _RootCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RootCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD7CEC3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color(0xFF4E7C88),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
