//
//  SAMobileCaptureBootstrap.swift
//  SAMobileCapture
//
//  Swift Package Manager bootstrap target.
//
//  Apple SPM does not allow dependencies, linker settings, or resources to
//  be attached directly to a binary target. All such configuration is
//  declared on the `SAMobileCaptureBootstrap` target in `Package.swift`,
//  while this file satisfies SPM's requirement that every regular target
//  ship at least one source file. The `@_exported` attribute lets
//  consumers write `import SAMobileCapture` without ever referencing this
//  bootstrap module.
//

@_exported import SAMobileCapture
