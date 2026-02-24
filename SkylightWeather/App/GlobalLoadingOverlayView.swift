//
//  GlobalLoadingOverlayView.swift
//  SkylightWeather
//

import UIKit
#if canImport(Lottie)
import Lottie
#endif

final class GlobalLoadingOverlayView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        return view
    }()
    private let animationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.22)
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        return view
    }()

#if canImport(Lottie)
    private let lottieLoaderView: LottieAnimationView? = {
        guard let animation = LottieAnimation.named("loader_infinity") else { return nil }
        let view = LottieAnimationView(animation: animation)
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
#endif
    private let fallbackLoaderView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        accessibilityIdentifier = "global_loading_overlay"
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAnimating(_ isAnimating: Bool) {
#if canImport(Lottie)
        if let lottieLoaderView {
            if isAnimating {
                lottieLoaderView.play()
            } else {
                lottieLoaderView.stop()
            }
        } else {
            if isAnimating {
                fallbackLoaderView.startAnimating()
            } else {
                fallbackLoaderView.stopAnimating()
            }
        }
#else
        if isAnimating {
            fallbackLoaderView.startAnimating()
        } else {
            fallbackLoaderView.stopAnimating()
        }
#endif
    }

    private func setupLayout() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        fallbackLoaderView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurView)
        addSubview(dimmingView)
        addSubview(animationContainer)
#if canImport(Lottie)
        if let lottieLoaderView {
            lottieLoaderView.translatesAutoresizingMaskIntoConstraints = false
            animationContainer.addSubview(lottieLoaderView)
            NSLayoutConstraint.activate([
                lottieLoaderView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
                lottieLoaderView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor),
                lottieLoaderView.widthAnchor.constraint(equalToConstant: 116),
                lottieLoaderView.heightAnchor.constraint(equalToConstant: 116)
            ])
        } else {
            animationContainer.addSubview(fallbackLoaderView)
            NSLayoutConstraint.activate([
                fallbackLoaderView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
                fallbackLoaderView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor)
            ])
        }
#else
        animationContainer.addSubview(fallbackLoaderView)
        NSLayoutConstraint.activate([
            fallbackLoaderView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
            fallbackLoaderView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor)
        ])
#endif

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor),

            animationContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationContainer.widthAnchor.constraint(equalToConstant: 158),
            animationContainer.heightAnchor.constraint(equalToConstant: 158),
        ])
    }
}
