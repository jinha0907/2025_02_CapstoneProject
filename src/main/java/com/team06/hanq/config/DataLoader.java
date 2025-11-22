package com.team06.hanq.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.team06.hanq.entity.LifeInfo;
import com.team06.hanq.entity.CultureInfo;
import com.team06.hanq.repository.LifeInfoRepository;
import com.team06.hanq.repository.CultureInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.File;
import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
@Order(1)
public class DataLoader implements CommandLineRunner {

    private final LifeInfoRepository lifeRepo;
    private final CultureInfoRepository cultureRepo;

    @Override
    public void run(String... args) throws Exception {
        ObjectMapper mapper = new ObjectMapper();

        // ✅ 1️⃣ LIFE 정보 로드
        File lifeFile = new File("home/ubuntu/Explanation_EPS.json");
        if (lifeFile.exists()) {
            if (lifeRepo.count() == 0) {
                List<LifeInfo> lifeData = Arrays.asList(
                        mapper.readValue(lifeFile, LifeInfo[].class)
                );
                lifeRepo.saveAll(lifeData);
                System.out.println("✅ LifeInformation 데이터 로드 완료 (" + lifeData.size() + "건)");
            } else {
                System.out.println("✅ LifeInformation: 기존 데이터 존재, 로드 생략");
            }
        } else {
            System.out.println("⚠️ Life JSON 파일이 없습니다: " + lifeFile.getPath());
        }

        // ✅ 2️⃣ CULTURE 정보 로드
        File cultureFile = new File("home/ubuntu/Explanation_KIIP.json");
        if (cultureFile.exists()) {
            if (cultureRepo.count() == 0) {
                List<CultureInfo> cultureData = Arrays.asList(
                        mapper.readValue(cultureFile, CultureInfo[].class)
                );
                cultureRepo.saveAll(cultureData);
                System.out.println("✅ CultureInformation 데이터 로드 완료 (" + cultureData.size() + "건)");
            } else {
                System.out.println("✅ CultureInformation: 기존 데이터 존재, 로드 생략");
            }
        } else {
            System.out.println("⚠️ Culture JSON 파일이 없습니다: " + cultureFile.getPath());
        }
    }
}
