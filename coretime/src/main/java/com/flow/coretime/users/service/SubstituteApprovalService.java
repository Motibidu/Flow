package com.flow.coretime.users.service;

import com.flow.coretime.users.mapper.SubstituteApprovalMapper;
import com.flow.coretime.users.model.SubstituteApproval;
import com.flow.coretime.users.model.SubstituteApprovalRequestDto;
import com.flow.coretime.users.model.SubstituteApprovalResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SubstituteApprovalService {

    private final SubstituteApprovalMapper substituteApprovalMapper;

    public List<SubstituteApprovalResponseDto> getSubstituteApprovals(String delegatorId) {
        return substituteApprovalMapper.findByDelegatorId(delegatorId);
    }

    @Transactional
    public void addSubstituteApproval(String delegatorId, SubstituteApprovalRequestDto request) {
        SubstituteApproval substituteApproval = SubstituteApproval.builder()
                .delegatorId(delegatorId)
                .substituteId(request.getSubstituteId())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .build();
        substituteApprovalMapper.insert(substituteApproval);
    }

    @Transactional
    public void deleteSubstituteApproval(Long id, String delegatorId) {
        substituteApprovalMapper.delete(id, delegatorId);
    }

    public boolean isSubstitute(String actingUserId, String originalApproverId) {
        Optional<SubstituteApproval> activeSubstitute = substituteApprovalMapper.findActiveSubstitute(originalApproverId, new Date());
        return activeSubstitute.map(sa -> sa.getSubstituteId().equals(actingUserId)).orElse(false);
    }
}
