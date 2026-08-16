package com.miamai.api.preference;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/preferences")
public class PreferenceController {

    private final PreferenceService preferenceService;

    public PreferenceController(PreferenceService preferenceService) {
        this.preferenceService = preferenceService;
    }

    @GetMapping
    PreferenceProfile getPreferences() {
        return preferenceService.currentProfile();
    }

    @PutMapping
    PreferenceProfile updatePreferences(@Valid @RequestBody PreferenceProfile profile) {
        return preferenceService.update(profile);
    }
}
