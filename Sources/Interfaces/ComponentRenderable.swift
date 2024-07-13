import UIKit

/// Represents a container that can render a component.
public protocol ComponentRenderable: class {
    /// The container view to be render a component.
    @MainActor
    var componentContainerView: UIView { get }
}

@MainActor
private let renderedContentAssociation = RuntimeAssociation<Any?>(default: nil)
@MainActor
private let renderedComponentAssociation = RuntimeAssociation<AnyComponent?>(default: nil)

public extension ComponentRenderable {
    /// A content of component that rendered on container.
    @MainActor
    private(set) var renderedContent: Any? {
        get { return renderedContentAssociation[self] }
        set { renderedContentAssociation[self] = newValue }
    }

    /// A component that latest rendered on container.
    @MainActor
    private(set) var renderedComponent: AnyComponent? {
        get { return renderedComponentAssociation[self] }
        set { renderedComponentAssociation[self] = newValue }
    }
}

internal extension ComponentRenderable {
    /// Invoked every time of before a component got into visible area.
    @MainActor
    func contentWillDisplay() {
        guard let content = renderedContent else { return }

        renderedComponent?.contentWillDisplay(content)
    }

    /// Invoked every time of after a component went out from visible area.
    @MainActor
    func contentDidEndDisplay() {
        guard let content = renderedContent else { return }

        renderedComponent?.contentDidEndDisplay(content)
    }

    /// Render given componet to container.
    ///
    /// - Parameter:
    ///   - component: A component to be rendered.
    @MainActor
    func render(component: AnyComponent) {
        switch (renderedContent, renderedComponent) {
        case (let content?, let renderedComponent?) where !renderedComponent.shouldRender(next: component, in: content):
            break

        case (let content?, _):
            component.render(in: content)
            renderedComponent = component

        case (nil, _):
            let content = component.renderContent()
            component.layout(content: content, in: componentContainerView)
            renderedContent = content
            render(component: component)
        }
    }
}

public extension ComponentRenderable where Self: UIView {
    /// The container view to be render a component.
    @MainActor
    var componentContainerView: UIView {
        return self
    }
}

public extension ComponentRenderable where Self: UITableViewCell {
    /// The container view to be render a component.
    @MainActor
    var componentContainerView: UIView {
        return contentView
    }
}

public extension ComponentRenderable where Self: UITableViewHeaderFooterView {
    /// The container view to be render a component.
    @MainActor
    var componentContainerView: UIView {
        return contentView
    }
}

public extension ComponentRenderable where Self: UICollectionViewCell {
    /// The container view to be render a component.
    @MainActor
    var componentContainerView: UIView {
        return contentView
    }
}

public extension ComponentRenderable where Self: UICollectionReusableView {
    /// The container view to be render a component.
    var componentContainerView: UIView {
        return self
    }
}
