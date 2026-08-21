import SwiftUI
import Compression

enum AppLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "appLanguage"

    case english = "en"
    case arabic = "ar"
    case vietnamese = "vi"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
    var layoutDirection: LayoutDirection { self == .arabic ? .rightToLeft : .leftToRight }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        case .vietnamese: return "Tiếng Việt"
        case .simplifiedChinese: return "简体中文"
        }
    }

    func text(_ key: String) -> String {
        if self == .arabic, let value = Self.arabicStrings[key] {
            return value
        }
        return localizedBundle.localizedString(forKey: key, value: key, table: nil)
    }

    func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: arguments)
    }

    private var localizedBundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    private static let arabicStrings: [String: String] = {
        guard let compressed = Data(base64Encoded: arabicPayloadBase64) else { return [:] }
        var output = [UInt8](repeating: 0, count: arabicPayloadSize)
        let outputCapacity = output.count
        let decodedCount = compressed.withUnsafeBytes { sourceBuffer -> Int in
            guard let source = sourceBuffer.bindMemory(to: UInt8.self).baseAddress else { return 0 }
            return output.withUnsafeMutableBytes { destinationBuffer -> Int in
                guard let destination = destinationBuffer.bindMemory(to: UInt8.self).baseAddress else { return 0 }
                return compression_decode_buffer(
                    destination,
                    outputCapacity,
                    source,
                    compressed.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        guard decodedCount > 0 else { return [:] }
        let data = Data(output.prefix(decodedCount))
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: String] ?? [:]
    }()

    private static let arabicPayloadSize = 262144
    private static let arabicPayloadBase64 =
            "eNrFPdtuJMd1v9IRIMACkrElJVagJ8kSYtmw7IXXDpDAwKA50yTbO9M96enZXToIoOVll6IVOELybki0xMuSS3O5XC7lN33F8FVfknOrqlOXHnJlBXmwV5yu" +
            "y6mqU+d+Tv37K/lk0pvOltqyHRWvvP3K1db8eH46P80+rJfKUfHjYtrmo/aVv6V2g3ySw69lu9YvhmVbN7rD/IurrauN+d7Vw/ne/DDqP6jH47rqDUb1FOeZ" +
            "fzH/6moTWq+7b8O6ok+HV1vux/oOTXK1DW0f6NaDvBoUIxoKBvoKJv1MT1PkAt3Z/DiDvpvzfQD0sWuynAN8Q2zzYP7satN9uFs007KucGTs9sX8fH4Co59m" +
            "r76jYC3uloPCtDm6egQtnrrPTbFU1y2v8xI+ncwPGIjD+TNY+I6eryrut2agQ/z/qx33cSkf4AbADh/BFlwq8MuqnK7y8h/S9Lj82WSYt0XPnuYObOY2LBCO" +
            "5xCWfwI/PHbNxsV0mq+EDf1Fv/n6D/4BVp7NLwGwj7Mfl+0Hs6WeGyNfaYoiPCL5Niyn43I6RSAvYe4tM/YLgvc0g9M5gmlOrn4/34Nek7wdrPaKpqmb3r2m" +
            "rlb6k3w6vVc3dEobMP+WbCP8xylMB8DCXuI/5/Nj+I/j+QFClrdtUy7NWjhEuxPwfftqk1YTtPCRH1e5Df8iCstMz2iuy6DbqKzu9KfFoBVUOYUu+/OLxZ1m" +
            "zcictLQPGtSTomKUPDRom244Xc0bAfkZ7iXcvIOwfV0t1XkzLKuV3rQtJmbmJ/MLAO0ADxUO7SGjtWo7yquVGaBF3+7dHvQ5xPPCe3Z4tdHRXu/kDhIDQMwN" +
            "RDxEeDgmPHUcYw8OYx3PnOcXpLgkhMP/HfY6JlgtqzaC5wD+oS0/pIVfMg6o7veKEdwZtxxEHkCVfYIA/tnIAGt3DGokOrprAnPA3hHK/QsA9dOyLNNdlvLh" +
            "iqEOV4+oiz2eM1j1DoP9UWJWIT9Tt/32MhJWlr+4bZDsBNAVkfWgYwR1IEhUDQXC3V/nvafbLVebBn04v0CizPi/C1cTqPnVo15GBAJGOJ6/iGgEN5abGEDW" +
            "6wBtGchjQRT60fzPeA6KjL5NawT0/N6r77zm918q2pzP4QjwaQdOb8dvUFbIcEb6sPHMkPqbKw3U/hGT5HRXnypyZ9moC5wUdgfOEsnlOjS4zPRyGRe35+dE" +
            "bZAzwcbSeT9188sye+npmeHBwNBtEwe/zCzEiir9CRjbGf4w/wSReAtvE6Lx/M/weSMrbpcrVQaQIMjr5uQf44YFY1jUFFKyD3MddMAGaI3AbeJkHoS3y2Fx" +
            "GwSCApDmajt7d9Sqv96c/aquR1P+42fl3eK9umrzsiqajml+C6x5qSly4nyMnIgRr7+FCzqGrZe//7H3Vu91WD/irQOIj+oLQisWSLxtz0hMOWP2gb8f4+bR" +
            "Lnzvp2bi1zogs2gLI53Bhj5htmYxykcGc7HMzICEJ/DpYWbnyQCZ9hFT9mISNsynqwRAr7g/GdVl288Hg4LZ6bmQUUtWGBwWqTa9zjDNcK3f1iSyYd8jvNG4" +
            "D5uEE8iZd6I+/zYDya0fyEg8FV0Ir/msyu9Cy3yJSQ1TAlnOsdeSV9Cv6rYvc/DwsHhLYvjC0VRqmd4wyCaVCMrc0kqiTujUK1puiumq2kIrDy2eSsAEJFB9" +
            "j4jl/ueNYG1mACofIE8rAuB158bL64/qwR3eo52rPyi5wMndiDAnRM7xU4gZgOuMVQFOsQDbr/KxsPgzwyCcMOtag7QxvAcSR39cD1noviC6/7S7ixy1I/Ry" +
            "vHsA7iGRY+EWhlqS4nAEoP+eadk6SlOyOHPC0PyBYVQv4N8tJrjrBMxneP+2Fy16Vk1nk0ndANY5wBSzyeBCI0M78pihu52OcyJP9Hnd20Kjej/45qP/hn/e" +
            "6t0HaIRO0W9EruS3N35Iv8E/P3S/Qd/s/eJuMQL8brIfAa/LXodGfw/fb82WRuXA/faGvzDQzvpLTX1vWjSG6Z3Dph1nRPCNTiZc4AJ/ZB7vDZIegBaJ+x61" +
            "p1uoOtlreIO+0i0iqJew+8/5FPFQd0V1U4sguQW1ARRG9ki0Sq/N4ILBFKHGCYEjeTNyEu2nfUD7Cm4/g3gMS3lh5hKxVnPlS0LGA0vWlfYXXPzk1Bo/nYZp" +
            "2YclrIJynX2dCCPIHXXlzQNVE29b7zfVbyofm73vb/+m+uajz2P8Vj9rFHc/e1iufu5C9KBJhPTegoUn561S1q2I47W8UzRVMepD83ZG9JvWZgjkQ8STgGhL" +
            "D6Dd5uwtyadpAA0u8Sy/+ejLVD/EnbskQT6EU79INSkr28gcTty2qOByTJpyCsoVyHMMii/oGEJ5Cd1PlFh69QiJpyeYWHGvp+S1q20rrF1tG0ntatsT02L0" +
            "CQnrcgFbCwzWqDxW4k22UkwB9/FTcycO8a7Ctj5gUZG1VSQfcse18YCVSZJ4oRuseTMgAQhgmy/1Vutx4ZTuL2GoM+HR+HUZBBwFtSNV+JEMEvazk5VUEzQ0" +
            "VULA9Ark8z1A0EkOSG4HUetBYw53d2aKcBDTYFSOS7rZwH9ZnTNbRYIAiJXzE9Xck8ecbHksQl9igmkxKgYsjVnx4sQb07QAtXI8zps1aPnqaDTM3JZnX1+I" +
            "kcx0GcAFVzT+kEWALxA36AL+rFxqYKjvv5fjRgPeteOJoHQPB96Hg/3YENczAvxE0Xa6iM/NkeCPZ/CfZ+5ub/F5om0oE9nbEe6e3rDJBEh92a72BwhKYm1k" +
            "X8LrtWPlep8tzf8EYB8SZnmj6uUj8p7aOxuzLFnUDqI6otojNlGkpsmoyz6tlU7V7mrPO4G8quDMBvWMbSd4AMic5+cZrjBsGlA7aYkcE2SqU2fFDIF2cDFJ" +
            "dEiTN4NVg9lkgpVbm5JF/F79Yjxp17T5BZX+T0ngZnHVnQ4RDGTA2AIJyPH8KSvkW2gsokuHnE5NwqNbQ4ElPfu0HiRMm1FrZRvQKguu5XL+mHXKFHJ0HRXv" +
            "RXALaC1wEXrR5QNOZ+QSNgwdieCrJCDWak6Cg+3nK0DKY4M0H7BqTP/2l2Zty1zVERrvZtO/adYo7X08GNTVctmMnVHreP5nEeUjEdXh0vyPiSEUPpzRpcSB" +
            "mBeyIfxLllo6iAuZPMO7LdSOlIAeGr6+QkGOZEVkpAmc30WdhVAKT5c4ryhn+2h+nX+GTTZAHDnF4R7T8j7zBMJ98xuO7l8wtwO9TKwtbE81oJySqnRJbN+T" +
            "aC1K9BI7l1trteK02Ovzq4eqOXDo2ahV5l9Up0ji6GRP0kVbSvl+HpOZ7pRk0H2F93QCzHCJ0F/CEk4zjW10RCjVnNMWojzg8XZLY0nPLMUvpdhYgoX5bdEK" +
            "odmeFXIizgdStRMCTomf7COJOTPK/zEI6VtBj/4ob1bIilI205ZdJHKAiBn77DMzlldAkvP5V/PTcJDpGESIjlG4hz8KjxxRjj5ar/iUPOvHiahSrCihjPDl" +
            "/Mj6YnyxJBB/uEk+HDJVeY7eHya44vzIPOsSN6+Kezy9fMjQAyT0iluU44nZbuL4rGGdZD0xlYuX6L5pdYhmaDq5oMXQGFxCGALCj/cLGTtCkll/yk4a/ogl" +
            "7ZLY/qVaNvsVWIClFQBXQAJhOBKB2bMjsoGnP2nq38I5+ZsDZ70OHMJN3+YTNOXNKuzFe/QccOCCReMTNF9gt5SvzI5hnGo4ZasvC0rt5BCR3lHPZgaYaEUJ" +
            "vsLrZNBhdkIa/D5KaApkmOrOdJKDRg0C7Djobi848UGS8fbQjScsFQmEHeg6USKFnVqQiM7a74OzXxCbXicZLh5ggSSikb5LEjEfzgi/PCShEYgWulNy+BB6" +
            "FL0GCQteonGLpKgFtl4N3YW2gDnx+hHsxwO1fHd43FWb8wTxmfNuAQHcxD3VAwtjis72UjETRwj2yHbiyUmWf1g2KF4oMsP8+tc/eZ/baUMQHiOOZMQ9Xsgg" +
            "n6DqiYIw6NRVq9UcFOo/tsYq+HOd1PBwB5CgKGGeLZPMdGkrUA77hJxmSJOfESM+CDYE3RFbvD4yY0Wbws4L1HGeWLeA0Up7MVAmxKHz0pCNzmuuTalabgwp" +
            "nVv4sGhBm1RLx6aktKcXuUXW3Wf4BXk7HMU2m99wTnSp7QUSldXmLCknj9ZT2qyHhJZ0bRk/jHjndsmjrPYKYDQDK0NCaIuVfLDmqWOWzq7Tf2yJ8K/CH+6+" +
            "Tr7PF9yIkJPt05vWeP+ECJ7pa45YsN4Tzcyg1vXqgOu0Q8jnejR0RgRz27wmRJxNg3WyaV0qtgp8uo9NAmZtybfHN23LxPX0Ww/JN6JtcEhc0YVomwjlgD9W" +
            "vc1/AqcmllzFRZKUM8QWj4oChpzRF0IKkYUMRThYZAHvhTCiRDiblcMOP5+GTWE8eiC3QMTfzAb1GNAMw3NGd2v0dRf5VEgXou/8HKCPqVbAGrLv382bDjLW" +
            "FJMRXMkxULA+ogzLg8Yp0sGBB6t1PS1Me46eIGJ5KmTAw8L+tPydYhEs18azo1+sbER26IDALGKb/IUGmLxaKfpqqECMicHL5p/Db6eBhIgeuWAUp4h6kmMn" +
            "fKyiBmhvokxQC2FS6ZRAjaebSaqJAhqNohyuZnE6zkIPpAkRXx6heIwVHcAjUogXpTdoirylKzYwIWHMkFIirCgEjuKoDe8gP0g8tKZkCUhAoPopGxL5zbaM" +
            "PKu5jqFj+hxkoLTE1kkZ+7F5hsUFY7JThNjJKpcmPMMCRco5R+dYjdssVg5FCIzd116wsaGxTalaYnDzd8wadhzNYVuEFcv2fB+TktPMT3LJiN8yuTr07k/i" +
            "Zm4y4TU0x8ho4lP2RIJwhahL+jokMz6FY8AWvKY2RDNb1GsC9zlv8GIvN/VYuRY1LsH9QOdCFm2NA1jjk1wNPaALa3CGB3Vj0uLQdaGIsXpVT/BY85Hu4QIX" +
            "1a0Td0TQ3Tr+ERg0WCMunpD84yhyVesYSRtf0q3C2eHL8XjWoofA43UKpsjy5MfxGfnX3zinevTiKYv7JQdSOCWiY4ZAbpLQwCwpcycmqquBF7VnQbVIyDLS" +
            "A5Rr0Ax3RAL0J6RfALHfCCBQkUMPxI8SKA9kDNyZn6VVbweiU9xTwDh6O5mM1iTe0Bi402jZgPxVN4V2oCvjbiDk72J0iIdtNJE6DxWNZEMozL5w8IOoe8oH" +
            "/1THOiW3DYUcVtmE6DBVEnC0LC3Q9wIAI+uxEgbVhE6f/2PHANp27LxRQYS2io9E8ccE+Yno57aTlm6iDCJCLVIpmXBZbaWfniw+mYwwkS/hhci05lR2OajQ" +
            "6FGkTqowFw8h4i17CfRQ28fkcxhZdt2116aPDrbB4eDDpHmYQ7A6B4m9dtddMZYOE7P5QmGXOY5vaHLF8YXt2dBDDgRLYn9E+7VXQSnNpEjvoqR79XFC1e9P" +
            "14CshXCxwcNoygfXmln8m1UmD8WSHIv8Vp0MTwfP5lshdYSwiYW9DMr2gvwBP9KrGeetxBrDxjOpxiEs8XIrEhvCuZzOwoFdpoiKFE4SpMxp/2L5IyHvsTIF" +
            "ZHQZPjXxiIrCOaLs43AImuN/DVz/pplN2psnThgXC6OA1vrNLoXTldXdfAS6sjMqounriYQERzq8wivZXNwJZC6Gd4pm7PTixN7ny2xJ4D0/QgvsLt1AWOa2" +
            "OEZYOg5MrZ9T1N53ZS9geFBT7lNkhgQ3UGztNl76xBVfrM7R8StnUhBdGE49nMHtHaBky6ZdZt6sUx5yzPPh/BljCikxStWJEOwhXKmzq0ddB+y5JjRzTJmc" +
            "jS2v27jM9htRzIzJNjZhhtB0GB9cMohZ22I9R4Hi3SyST8I57xRrg1Xxm1tVQSQZJQumBUsTdsPyJJ++CVQ95PCsXQo9fxhOi9GcQUx1hynMC+17DCMeWkTz" +
            "RGs2ZSBHIpblIhccW4VeO54unOAZgvZrY8x+iuT3hBQUGhAt+blk/+cpMRbKmzpFPpa69UoYNl7iDqm4l+k0F89HTquzohMhnRWeMgKa/D4x0lnx2s7+ElxJ" +
            "nzHvuxE6PQkbte9tDmIhSwXipo6i98KOOy4piz19ORiVjuZLPcGZWC5AV6CX+WkNZpAPfvWrW7c1CXVUMylDmb0bg1rRd/5cz8v/1PEXBY/arpDWuNQ2zgLZ" +
            "46BxlUJIuX/aw8/ej1G9Mg1y6s7IAsRmpESPadGinhr28nLUop43ShS4Nm8jAY0kAkRmSWOsUelFUdKuD6HLRHCjdUGmr0dgZMpU9kHXXAT5StmuzpbcLups" +
            "M04kTfcDhmOM217gP1I7SuACBD2nzC+/M5x0H9gDhSYqd7g7crLAvc2RTBwN3EOTf962aD90qSj6lm4ZXCO1WXrVd/p3y5zDxihpwVA0PTSbmUxDzqChRAMA" +
            "4jXXTEuUoG1N2ZMSRtwK1OOiXa2HIHmMZ6Mc0WLSFHdLCqogqWuP/LIHGvQN2imD035MR4jStpXJuTROHcq01A3KeqrkX+XcKn9xW7czCJcOvo7w3/aTPTGA" +
            "4i5s6e9q11LblRjKxDkkWgzqMVAuQSMXhusSml3LWdOgBNKZJC7Cj0njth2hQ7lcOqVhGnXVNl6f5lN2tB0JcyBB6C5HwyATkmOmTAyubT80gfZ9r2cQf39d" +
            "3wnF4l8/xPe9qP30qArfyRnkAoqjNNX/h6waDtDvSW53aEARVA1TB6TTgmSvG/Q2dyWVdnCjodjwHYw2nbmct2QSsEf7b+fVcKm+Hw8T5wLeYEVsWVQ5NC5t" +
            "1EbuuNBHiYuGQUQuEXN3z6Zz0tQcZXHJETxeUk1SadYUPGVnEVDzWVvjzgfnpqIOTJKFlgnsjGrNTPZFR5nCf4zyWcWOuZuCHQTpqhX00hcpkVhtJHyTq5J1" +
            "kxtyOPG2XNJ5PlJB+Fd/EPN5lIb+xltG3qXNTKWJZJKvqyOlQ+LmL4nxr9/WdwourIB6gUJL23KlqIqGNGDTNHDiUE+P9WHDYIek6IXkGYor4DpBzYN40KCE" +
            "Zun5M3YfmPyEdY5o8ZZYD8oc88yHLBlsk/7xpYuvxUt0zuyQmvZYkOo3tUvo2MCMD3N+eDCnbEm3JQWkK/Dpu5XpSdLyIWVsw/n9888xTJSg760BIf4tljOw" +
            "ESYXbKs01u1zOK0t1365bgaI4G1MGZfyYR9EYaDnrnU5+l0+BQIMrf8J//s2/Hf2zUf/k334wbt/994bPM0G3Yu9yEBhkgN4rAmaZ9v+pJ7yKd6iv7Nb9DcM" +
            "9PPZygr8TWmlO1QfotcW1bAspm4Mg2TFdJBPrDC0S+dwpkwWJu5jk4xKqKzuM8kUdGQqZlfkJqgnOWfu7VCoIlYN2Mjeh1/HZYWJVsr/f8fwCwddUZNkSUlN" +
            "5nMfOr/55t9DqxUWuXtRyR4ni5sm4vygkItp0p+kchjDfsnoftOfOY0/j9NQ8CT3jZ9OVwUK6Y1nlgq1Fzu65V9xnrXfpr8CAoVIhIccVBklRTtKEvQdFlXp" +
            "usKaH8yfX9eV5nP63s3m8wN34vUu17NqaErqHElml/mIBXWElW4hjQ4+32vKtlhQKMCpdUEnMTSZIDfG+VRjrCfQr6sRR2f4ydcPJHQy2FnnYV6gZfoapvDB" +
            "Rfja0ytwSbqHlBHCJNd85ugQJYV4W5+R7eZ0/pUN1QLu9V8+n+7IGjYTmJzhpkV/DV9KzvUK8uODDlihZc1SIJKfLk1ezimybXaOxv2ruir6dVOulBxhYF3/" +
            "39MWqNf0uQ3zpr9c3hdtjQ8iI7PtjklGM6rZL99/95eq62A2betxP10ywDnHUSunXCILZO5SL6l15455TBl3/FOzdZ6NmSawdudUCQKbiE3U+nnPxGl5xkBc" +
            "HgmRlCz7QNly0Sz7mJ2FErN1Uww0FRLMei9pQH01sSIY0OKS9+QcwDukiiAu5sSVBrM7v4rWfedjsD6CZwDrQ80MODHgXn5HIdM61UgiIsxs9IUeGg6nyVWm" +
            "11MT/8URrLRG7y6TOhS399PQ9AxNPl3F6GFXJSti8iDowAZTAK1GjnI6GeVWE39G4cSaCMH/w7aM8wr+aQzhfWEQBeUnikHNbmO77ENppxYzupevTYGM9dNT" +
            "WdUjVbfNDlKjcWcJWMBgjUuM7ehKT3aoPYnV/VJKNdlFrIHIMrbHxWUK1HdTdKacAMXFVFImb7aIj5+RVt7Kh/4WUnRPU6zgsZmwE7S1XkjMs3JTYKkLyXvQ" +
            "PL3oT4pqUCKBeRf/zG7xn4qyjoAE+XaT3atHNsrEHwzkg2IEHWCQwg75E/2j2pxiMGswSwtUKJv4sUtpH3vGRyq2Ys0dsTxJfzqp62UjGSHK7eExdFQscQRp" +
            "OaccNlPhhNCTCAP2ew60WOpR2fOBc6mnJiUbyQ3K1XAMZAFzpwiETYi0RKyTZSj83kdPg7O4SYD0jrF9L+zamX4f9PXOZFzAP/3VGYoaH+J/Zx/8+n2P0Q8w" +
            "hnlNUXDn9/DaQavWY0bsxNvWMp5mS15nIouu2MW1FTMSEGrOLrmYiNGXWaJIRyiQurJl2hceRH2ZInUokaPg3jMRDVQNZJ9jIKI4BxZqUtqu4+JKdvRzk9Ji" +
            "LsubJhVQoj7SAqdOUQ1uIpohdWG4v0l87w4L4cStfaqZ5bHAl4rkYFzoKU7bVSkTp0AfjrNcW/eNOSg07x+YZn7tT/trPVlje70JV+FhzPfugopes0W5g87l" +
            "wLAlOgbxZyIicg7hRdLU4DRw8fY8QszN8D7zZxVpIBuhI8O9Ong3LQlkOnelGblUpVRjr+xglJpn1xNGgh+a0Z/Thfv6sQ6X/wjo6iqIvFITBMUGWsfXf1EQ" +
            "jOp8mFZaJf6clVbT3ISYa7+yDU0mdzEH+Pnb042xvp1x0+TWRy5KM39TWE9V1zC6tdSTPRIntI6T0ZkApmbL1KVw2Nw4b/JpPbqbiNRXsdloEKFSqJ/5G8d9" +
            "i0QYuAkY83urrrNKOg+9xIhrh8j0MWaeQmGGfrlKE6YXVejwU1K966Htu6bPeDXvLyiWwSYtf8sWpL6qVpwSIHY65Nv6mzYahFjcdz0TeQ5WvfXOkKJpVElV" +
            "ScAhw58kucUxvaI4h8FLHJYQjO0sgy4hyW+SuqyJBJ0QZqwT3Q8Km/qhVBbSrt7J2FDbn4oVWFsw1YRIDERRDjok2YsPuREsMgQn5zrLjtrpMHzKRu9IzT8x" +
            "EMW0RU8wrWcNRsRr01FXFJoy0GVBJcfedSsYliCRgQiwFof2J2exSYwZVR1NF7FYuCQ9YxAJxrF+Ni5fZrtmo0Antnl1UWyTRK1zwK8sh+oWuvC5jmFtwJT4" +
            "JbZVsWgX+NRVZqtjz+uaK0wkEYYPEItBsHx7dN3SEzkxXYgcRK75BLivM1k1GU5QprhzR9qXrkyR6rEwM98c27bLUo+LAgWjElv4vyk/ZDlPWDgjwRCq4l6Y" +
            "5unKZXiNQs6RbIjYTWe+aponOSm1i1LpzE3e5dhSWwvL59NGaMPs7wteP7m2VJLrMZH7BxzgtcGhrQ4njc3Q0wOlZLZqCDp60bpCQtGXsNCQJi+yz5TlEPQK" +
            "agtJyWsc4OvHr77z9V+i2FX0lHpVh3oBz7Z1JBdy2tCKpm5blOeZ4prW8xlyzAo9Tn77SM+S3fW70oakpqLt8NtiYAWlgHfyxC/woF0wll2rFmSoqwlnNGhg" +
            "QsoX3WYdT96LRiRsJmJZW+ZqLch4jKYITbI35axN2aslWp6tSeTxLBlRFQ+LB4v4cEy3z7l6xA25MA+rcvA9Hq9Kcpik/BuKD98tj42h9ASFHVd6RwB+6Y3V" +
            "Y2NAnw+yWn7gf7SZIItB/yv4d0ae48WSzXfEz3kYTthalNsq+Bt3dcTXdU1Q4WtGcZTZRcy7Wm+d3RJhwnHo8kL5QyKgVV57XAQg0P5sJYEF1QNefSdQ5Xia" +
            "hdJ/AujkzJSlNyoHXrE1q2TZ6xnWJOwaRL9c4GXM0wB0j4SN6QE7xbOUsCg6f0I03EiB5qtqQSE5b6sSy6IHfkaBrTLMtrhulCi20D9c0MQpBSnUAM3vJmwX" +
            "/vbFxJHLiIkErZsWAnBGG2Wb1IaGWooIo91Zj5+wVarPk3zaiuB27hku6IMFSuqRBHW4yLyoYUNran8wKidUwzd4U+mS7CTnjmVJAexgcX16hCB8fCC5XtfU" +
            "shpXUCaod/G7EgOK/vUntzy5hd04KMaXd623+l3+s4ddlAxOv0YCkqWXMLR/+c2oCROE16urS3caLb7Gc4N7aORUWGKJLrVugTU4V8tCXkaAbZu8mi4XTZpO" +
            "qcGvo1TxQAlapSSrv5Ja3SmKSX+pbledvMfemj3212xQZfNHyENSvSyVW9hTQmS8dSKyJ4RmxnQflQDZky3xrvst7eZ1UFMqXGKTwjtZjjuD6wnrywwXUFjx" +
            "sDgKynFs11LatKxxHSE2kstg1kzplnn1qAIbDkPm5EzSIgg89KCIn9JUFUuZdUTEYnJteb72KUUE0Ya6JWUWHlDovBrQ1TP/VgMKzemSAneB+z2jKqtAqqR+" +
            "rcug3bVRJtpJ4yshsnc7KuWVe5mYSxxYg3Uf0AVuPVNsuMIbvDpSheN2kWEd2ke02IwZ02LTvqtxQIUdOG5jBBtefSelEtJQ3oHRCN62LjwfSWRWxxT05XcA" +
            "H9htDiqP23RW476m1LyEUF1NZ8vL5aDElBXryQsLnlq/3jFH4W9Q2os8URavTE8j2UcsDccXTmckRV4Ej9HkS1N57Amd2sb3sk9car+bCKHtC/rqrgdeR7GC" +
            "edIDTtY3/rRFziHbUEogKv/bjX2orFQZINP6lAKdhxLwPTEMS7jZUeTtzJfoCmytQEP90rRjBLUSve0muN/fljAI8AZgmF5e8VzPumMKKyqPth2355ubQM23" +
            "J29yBB/I/bgGC+yTDNo3/oQ40mmWeKLBtU9H1XLg+Y9IOI5bpyVf752SZBcbYase3ooSYr34XDdMssqr10JSJyQo70jnZ1M+mdcY6F1RqZQ1bGNzBmX5XgeT" +
            "Iwe8eNCUk7Z2hSs5s8GrobNnA5PcCFzCRgkWCjaUlDGjjMRbBY370ZzfQWpz4/eoVEiiOsuo3mjPx51mzZXU9w/He9NU7cpqMbjTFZ6QzsVS4DDrc6MBLb+T" +
            "rxRT75S1t5CKTgdbwA4N1TWIX5FBuvDf767vcVzn2iZdML5TmKu/g511vl22RrTc8OkRg082xTDeoLC8GdujxDmzTZxPlXOUWymJ8MeY7rEpRsI9fnDUlbBX" +
            "Ph5XmF/H7FFN7U3xkZiS/v4m5MuYHsfpEyuzclgElYUdV/kkk2DEYy6we6KezYlevRLYNTrTAneN/LDpOAC9ZEbRWc4yY2+QLblGr0r2yJxEe/ZifvB2pt5m" +
            "fOMtghADILhGFcnSbpz36pHUOZwGgWluM64LOHQtq7qvGgdYrIs8qHDZsLZ0EJLGaWrmNYQ0YJ3oZ4pvBL3SpdlSjYY6Vm7h0i0supTu0/BBQbMsk1Hp+dqT" +
            "hBgfnZFAtF2pt2y3TpdVJvWjF7/NJCKa2AFMJap989Cv5FVIfSBS4df9CGvv+RrFCkBQ1rHFJuJX3aHhsMSXtCzL3KEngR5k/iKtDGBLivmKqMJQb3iqBzxc" +
            "Q0fagEdnQwrW+qWw5p7HNU5I3KUAesy8j9iAMQeRm8vqqTsuVswVUEFNQPIIUSc74vcOtxf7IK623/vle15lm7SsUdbTN97yuOElIeCJzwTlIgf57fJ0SS+T" +
            "XK9n5gUWooAXNqHE8mxnv6EnBihuQgdXm/hFROMfypOu5G1G8vO8C9sMyOqpVcYkdqnLyzuUx/PCVTtBoExqvxScNk/O+TvE4fde2lyqgYk+1s4AG6Pv1e3x" +
            "3jIjKZd80N0j+i9Pm0e2xBONcAcCj6bI8qTl/I9M3d1LWtFGOiEs/UZWBF8x7C+t9Sn+M37VTJMTPggiJxIt6lE+Klvl60S20qkeMd130btiLwGUyXROTKBe" +
            "4E6B2IGUEs8RHC2PqA40eAtHH2II4nd6hgzIAlNiFB8gC+4aJY72/pbnsK0KQioi1EsxzK66ln71PbmG8VHQEIHt/KlO9JP3iUy8kGH0MdSmdhQ/BeWM8Kam" +
            "GNmNFXFazDNTZNtffxjeEux1ouyaaALBJiQCXuJrZElNp4BLMq3LO5eCmFQLb5cfv+q4JVKsLKUTXK8k+SpGqBsJlYqDm73nzz3hwNrqwrEYVxaE0HTTgwis" +
            "b+ESjXqHb3PpVGXFK2mDOmdfXBnVPsahdpxJlCoEGfOshEvM3/EOvdzrj6Ydlb7N+o6vxvhVY4/o/lyyJ8u93IZeLXlgpVtVQo3lsThm3VLlyZF1pFGKJuts" +
            "Pin+2r2McV7NTCaUrWB1s1H9FWoyaIugSIUqlV9sR+TSKPx4nbdt127GoqJqMemMDrsjyScte3qjXMc+ulSVgBD3MJrrD1yBFRfrSbH6ZcTH/opc7FpQ4Cb2" +
            "qnUbRnR1UpuBYeq97AUytTPeq6Kj2o4vpVi1tApndNlLzMn76NeK1EJ3ylYnexI6dOL63VboT808ytfqWWtecmGR387sLVdGjF+gJtPC4nqUvp1d7X8KJDH5" +
            "LCr066xSQYx1OJZyzQSOoW/tmonOrqOMZhRh62x7vgaxHYfRJ16IENmjq9JmBJW8/nLou/YSWsxBZh4e9srWEu5e2hcsAgcmb4d5+NSUjQyBqOrAeHzda6s+" +
            "kfB2yQvGM7EDQW3eJAa4qlnGhcpzWWsIGbu2lblL2251WYxtv8xFmBFqnI1Ji0IKtCVA9NnEc0B6xUyPksYg0qrZkJcZhz8Rf1dwJylxmjqjRhv2XRLWvLa9" +
            "uPaqf0K7bKKRwwoTGcN6VyEsqaqs+mzU87obkkEpZrrgtVQloHje2pi036nqe5V5m+VxhiRvvpug0ZlbejpL1bzA/YBgovTW//hf0f6Itg=="
}

private struct AppLanguageEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppLanguage.english
}

extension EnvironmentValues {
    var appLanguage: AppLanguage {
        get { self[AppLanguageEnvironmentKey.self] }
        set { self[AppLanguageEnvironmentKey.self] = newValue }
    }
}

extension ExploitStatus {
    func displayText(language: AppLanguage) -> String {
        switch self {
        case .notStarted:
            return language.text("status.not_attempted")
        case .success(let method):
            let localizedMethod = method == "Simulator preview"
                ? language.text("method.simulator_preview")
                : method
            return language.text("status.ok_via", localizedMethod)
        case .failed(let method, let code):
            return language.text("status.failed_via", method, code)
        case .unsupported(let message):
            return language.text("status.unsupported_reason", message)
        }
    }
}
