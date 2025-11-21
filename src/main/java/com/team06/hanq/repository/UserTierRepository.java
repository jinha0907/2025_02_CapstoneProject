package com.team06.hanq.repository;

import com.team06.hanq.entity.UserTier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserTierRepository extends JpaRepository<UserTier, Long> {
    Optional<UserTier> findByTierName(UserTier.TierName tierName);
}
