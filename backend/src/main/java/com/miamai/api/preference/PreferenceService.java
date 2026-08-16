package com.miamai.api.preference;

import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicReference;

@Service
public class PreferenceService {

    private final AtomicReference<PreferenceProfile> profile = new AtomicReference<>(PreferenceProfile.defaultProfile());

    public PreferenceProfile currentProfile() {
        return profile.get();
    }

    public PreferenceProfile update(PreferenceProfile nextProfile) {
        profile.set(nextProfile);
        return nextProfile;
    }
}
