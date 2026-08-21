import Foundation

enum ArabicOverrides {
    private static let strings: [String: String] = [
        // MARK: - Accessibility
        "accessibility.log_entry": "السجل %lld: %@",
        "accessibility.open_editor_hint": "يفتح محرر ميزات MobileGestalt",
        "accessibility.open_profile": "فتح حساب %@",
        "accessibility.requesting_access": "جارٍ طلب صلاحيات الوصول",
        "accessibility.run_exploit_hint": "يطلب صلاحية الكتابة اللازمة لمحرر Gestalt",

        // MARK: - Browser
        "browser.apps_count": "%lld تطبيق",
        "browser.archive_done_title": "تم إنشاء ملف ZIP",
        "browser.clear_clipboard": "مسح قائمة النسخ",
        "browser.copy_ready": "جاهز للنسخ",
        "browser.create_zip": "ضغط إلى ZIP",
        "browser.empty": "تعذر العثور على تطبيقات يمكن الوصول إلى بياناتها. اضغط «إعادة المحاولة» للفحص مجددًا.",
        "browser.error_archive": "تعذر إنشاء ملف ZIP. قد يكون أحد الملفات غير متاح أو أكبر من الحد الذي تدعمه صيغة ZIP.",
        "browser.extract_done_title": "تم فك الضغط",
        "browser.extracting": "جارٍ فك الضغط…",
        "browser.mha_scanning": "جارٍ البحث عن التطبيقات عبر MHA-C2…",
        "browser.move_ready": "اختر مجلد الوجهة",
        "browser.name_message": "لا يمكن أن يتضمن الاسم شرطة مائلة أو محارف تحكم.",
        "browser.operation_error_title": "تعذر إكمال العملية",
        "browser.resolve_all": "إظهار أسماء جميع التطبيقات",
        "browser.resolving": "جارٍ جلب أسماء التطبيقات…",
        "browser.root": "المجلد الرئيسي للحاوية",
        "browser.search_apps_empty_message": "جرّب البحث باسم التطبيق أو معرّف الحزمة.",
        "browser.tabs_root_detail": "المجلد الرئيسي لبيانات التطبيقات",
        "browser.title": "ملفات التطبيقات",
        "browser.unresolved": "اضغط «إظهار أسماء جميع التطبيقات» لجلب اسم التطبيق",
        "browser.workspace_subtitle": "التعديلات والملفات المتاحة ضمن «على الـ iPhone»",

        // MARK: - Cleaner
        "cleaner.apps_footer": "تظهر هنا فقط التطبيقات التي تحتوي على ملفات مؤقتة يمكن حذفها.",
        "cleaner.apps_with_cache": "%lld تطبيق لديه ملفات مؤقتة",
        "cleaner.available": "المساحة القابلة للتنظيف",
        "cleaner.clean_button": "تنظيف %@",
        "cleaner.confirm_message": "سيحذف 3105 نهائيًا محتويات Library/Caches وtmp من %lld تطبيق محدد (%@). أغلق هذه التطبيقات أولًا. قد يكون فتحها أبطأ قليلًا في المرة التالية أثناء إعادة إنشاء الملفات المؤقتة. لا يمكن التراجع عن هذه العملية.",
        "cleaner.empty_message": "لم يتم العثور على ملفات قابلة للحذف داخل Library/Caches أو tmp.",
        "cleaner.empty_title": "لا توجد ملفات مؤقتة",
        "cleaner.limited_mode": "تنظيف آمن ومحدود",
        "cleaner.result_message": "تم توفير %@ بعد حذف %lld ملف. تعذر تنظيف %lld عنصر أو تطبيق.",
        "cleaner.scanned_count": "تم فحص %lld تطبيق",
        "cleaner.scanning": "جارٍ فحص الملفات المؤقتة للتطبيقات…",
        "cleaner.scope_footer": "يتم حذف محتويات Library/Caches وtmp فقط. لن تتأثر المستندات أو الإعدادات أو بيانات سلسلة المفاتيح.",
        "cleaner.search_empty_message": "جرّب البحث باسم التطبيق أو معرّف الحزمة.",
        "cleaner.selected": "المحدد للتنظيف",
        "cleaner.selection_actions": "خيارات التحديد",
        "cleaner.sort": "ترتيب حسب الحجم",

        // MARK: - Dashboard
        "dashboard.access_footer": "تُعد صلاحية الوصول ناجحة فقط بعد التأكد من إمكانية فتح ملف النظام للقراءة والكتابة.",
        "dashboard.access_not_requested": "لم تُطلب الصلاحية بعد",
        "dashboard.app_browser": "ملفات التطبيقات",
        "dashboard.browser_footer": "استعرض ملفات بيانات التطبيقات والنظام التي يستطيع 3105 الوصول إليها على هذا الجهاز.",
        "dashboard.device_actions_warning": "احفظ أي تغييرات معلقة قبل إعادة تشغيل الجهاز.",
        "dashboard.editor_locked": "يتاح المحرر بعد منح صلاحية الكتابة.",
        "dashboard.enterprise_signing": "يعمل 3105 عند توقيعه بشهادة مؤسسية مدعومة. لا يدعم SideStore أو AltStore أو 3uTools أو LiveContainer.",
        "dashboard.exploit_access": "صلاحيات الوصول",
        "dashboard.features_footer": "فعّل ميزتي التنظيف أو الخلفيات لإظهارهما ضمن شريط التنقل.",
        "dashboard.kernel_running": "جارٍ تشغيل الاستغلال…",
        "dashboard.open_browser": "فتح ملفات التطبيقات",
        "dashboard.ready_to_edit": "جاهز للتعديل",
        "dashboard.refresh_access": "إعادة التحقق من الصلاحية",
        "dashboard.requesting_access": "جارٍ طلب الصلاحية…",

        // MARK: - Gestalt
        "gestalt.access_denied": "تعذر الحصول على صلاحية Sandbox",
        "gestalt.access_footer": "يجب الحصول على صلاحية الكتابة قبل تطبيق التغييرات.",
        "gestalt.access_granted": "تم الحصول على صلاحية Sandbox",
        "gestalt.apply_hint": "يكتب الميزات المحددة إلى ملف MobileGestalt",
        "gestalt.empty_warning": "ملف Gestalt فارغ. لا تُعد تشغيل الجهاز الآن.",
        "gestalt.grant_access": "الحصول على صلاحية Sandbox",
        "gestalt.grant_first": "احصل على صلاحية Sandbox أولًا.",
        "gestalt.model_spoof": "تغيير طراز الجهاز الظاهر",
        "gestalt.recovery_warning": "قد تمنع التغييرات غير الصحيحة الجهاز من الإقلاع. احتفظ بنسخة احتياطية مؤكدة قبل المتابعة.",
        "gestalt.stage_manager": "Stage Manager",

        // MARK: - Onboarding
        "onboarding.install_bad": "لا يدعم SideStore أو AltStore أو 3uTools أو LiveContainer.",
        "onboarding.install_footer": "استخدم شهادة توقيع مدعومة على جهاز بدون جيلبريك قبل المتابعة.",
        "onboarding.install_jailbreak": "على iOS 17 وحتى iOS 18.7.1، لن يعمل 3105 على جهاز عليه جيلبريك.",
        "onboarding.install_message": "يحتاج 3105 إلى طريقة توقيع مدعومة حتى يتمكن من الوصول إلى ميزات الجهاز.",
        "onboarding.install_ok": "يدعم الشهادات المؤسسية، بما في ذلك ESign وطرق التثبيت المؤسسية المشابهة.",
        "onboarding.install_title": "متطلبات التثبيت",
        "onboarding.language_hint": "اختر اللغة التي تريد استخدامها.",
        "onboarding.versions_subtitle": "تم اختبار 3105 على الإصدارات التالية، ويتم منع التشغيل على الإصدارات غير المدعومة.",
        "onboarding.welcome_badge": "النسخة الرسمية من 3105",
        "onboarding.welcome_message": "طوّره YangJiii",

        // MARK: - Patches
        "patch.apply_confirm_message": "سيعيد 3105 التحقق من معرّفات الحزم والمسارات قبل التطبيق، وسيحفظ نسخة احتياطية من الملفات الأصلية قبل أول عملية كتابة.",
        "patch.apply_footer": "قبل الكتابة، يتحقق 3105 من التطبيق والمسار ويحفظ نسخة من الملف الأصلي حتى يمكن استعادته.",
        "patch.bundle_not_uuid_footer": "استخدم معرّف الحزمة مثل com.lemon.lvoverseas، ولا تستخدم UUID للحاوية أو مسارًا كاملًا يبدأ بـ /var.",
        "patch.bundle_path_footer": "تحتفظ كل قاعدة بمعرّف حزمة التطبيق والمسار النسبي داخل حاوية بياناته.",
        "patch.empty_message": "أنشئ مشروع تعديل جديدًا أو استورد حزمة .3105.",
        "patch.folder_scanning": "جارٍ قراءة ملفات المجلد…",
        "patch.legacy_footer": "هذا تعديل قديم بصيغة الإصدار الأول، وما زال مدعومًا بالكامل في هذا الإصدار من 3105.",
        "patch.password_once_message": "بعد فتح الحزمة بنجاح، يحفظ هذا الجهاز مفتاح المحتوى بدلًا من حفظ كلمة المرور.",
        "patch.workspace_bundle_footer": "ينشئ 3105 مجلد الحزمة داخل مساحة عمل قابلة للتحرير، ولا يحفظ UUID الخاص بالحاوية.",
        "patch.workspace_detail_footer": "عدّل ملفات الحزمة مباشرة. تتم مزامنة التغييرات تلقائيًا عند التطبيق أو التصدير إلى حزمة .3105 المشفرة.",

        // MARK: - Settings and credits
        "settings.credits": "الشكر والتقدير",
        "settings.current_version": "حالة الإصدار الحالي",
        "settings.developer_beta_build": "بيتا المطورين %lld · %@",
        "settings.developer_public_beta_build": "بيتا المطورين %lld / البيتا العامة %lld · %@",
        "settings.social_media": "روابط المشروع",
        "settings.supported_range_summary": "تم التحقق من: iOS 17.0–17.7.x، وiOS 18.0–18.7.1، وiOS 26.0–26.6.1، وiOS 27.0 بيتا المطورين 1–4 والبيتا العامة 1–2.",
        "settings.supported_versions_footer": "يتم دعم الإصدارات المذكورة أعلاه فقط. وتُعد إصدارات iOS 27 الأخرى غير مدعومة إلى أن يتم التحقق منها.",
        "settings.verified_versions": "الإصدارات التي تم التحقق منها",
        "social.github_role": "المستودع والكود المصدري لتطبيق 3105",
        "social.iosvn_role": "مجتمع iOSVN",
        "credit.yangjiii": "المطور والمصمم الأصلي",
        "credit.filzaslop": "مشروع FilzaSlop واكتشاف التطبيقات عبر MHA-C2",
        "credit.pocket_poster": "مشروع Pocket Poster ودعم صيغ Nugget و.tendies",
        "credit.sandbox_escape": "أساس تجاوز Sandbox المستخدم في FilzaSlop",
        "credit.forcequit": "استغلال bad_query",
        "credit.opa": "جيلبريك Dopamine وأساس kexploit",
        "credit.seo": "نقل kexploit_opa334",

        // MARK: - Status / tabs / updates
        "status.failed_via": "فشل عبر %@ (%lld)",
        "status.ok_via": "نجح عبر %@",
        "tab.cleaner": "التنظيف",
        "update.dismiss": "عدم إظهار هذا التحديث مجددًا",
        "update.message": "يتوفر إصدار جديد من 3105 (%@) على GitHub.",
        "update.title": "يتوفر تحديث جديد",

        // MARK: - Wallpapers
        "wallpaper.access_footer": "يتم اكتشاف صلاحية PosterBoard تلقائيًا.",
        "wallpaper.access_read_only": "تعذر التحقق من صلاحية الكتابة",
        "wallpaper.additive_only": "يضيف عناصر جديدة دون استبدال مجموعة Collections الحالية",
        "wallpaper.after_apply_guide": "بعد التطبيق، افتح مبدّل التطبيقات وأغلق PosterBoard بالسحب للأعلى، ثم افتح منتقي الخلفيات. على iOS 27 قد تحتاج إلى الحصول على خلفية من Collections أولًا.",
        "wallpaper.archive_validation": "يتم التحقق من مسارات ZIP والأحجام والروابط الرمزية وCRC قبل التثبيت",
        "wallpaper.current_descriptors": "العناصر الحالية",
        "wallpaper.error.access": "تعذر على 3105 الحصول على صلاحية قراءة وكتابة مؤكدة لحاوية com.apple.PosterBoard.",
        "wallpaper.error.layout": "تنسيق بيانات PosterBoard في هذا الإصدار غير مدعوم بعد. لم يتم تغيير أي بيانات للخلفيات.",
        "wallpaper.extensions": "إضافات PosterBoard",
        "wallpaper.generation": "إصدار بنية البيانات",
        "wallpaper.install": "تثبيت",
        "wallpaper.install_warning_message": "هل تريد تثبيت «%@» الذي يحتوي على %lld خلفية على iOS %@ (%@)؟ لن يتم حذف الخلفيات الحالية.",
        "wallpaper.install_warning_title": "تثبيت حزمة الخلفيات؟"
    ]

    static func value(for key: String) -> String? {
        strings[key]
    }
}
